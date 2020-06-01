extends Node

var thread = Thread.new()

var start_mutex = Mutex.new()
var start_sem = Semaphore.new()

var complete_mutex = Mutex.new()
var complete_sem = Semaphore.new()

var queue = []
var running = {}
var complete = {}

func queue_resource(uri: String):
	start_mutex.lock()
	queue.append(uri)
	start_mutex.unlock()
	
	var err = start_sem.post()
	assert(err == OK)

func cancel_resource(uri: String):
	start_mutex.lock()
	var index = queue.find(uri)
	if index != -1:
		queue.remove(index)
	running.erase(uri)
	start_mutex.unlock()
	
	complete_mutex.lock()
	complete.erase(uri)
	complete_mutex.unlock()

func get_resource(uri: String) -> Resource:
	while true:
		complete_mutex.lock()
		var result: Resource
		if complete.has(uri):
			result = complete[uri]
			complete.erase(uri)
		complete_mutex.unlock()
		
		if not result:
			var err = complete_sem.wait()
			assert(err == OK)
			continue
		
		return result

func _load_one():
	start_mutex.lock()
	var uri = queue.pop_front()
	start_mutex.unlock()
	
	var loader: ResourceInteractiveLoader = \
		ResourceLoader.load_interactive(uri)
	start_mutex.lock()
	running[uri] = loader
	start_mutex.unlock()
	
	var err = loader.wait()
	assert(err == ERR_FILE_EOF)
	
	start_mutex.lock()
	running.erase(uri)
	start_mutex.unlock()
	
	complete_mutex.lock()
	complete[uri] = loader.get_resource()
	complete_mutex.unlock()
	
	err = complete_sem.post()
	assert(err == OK)
	
func _loop(_data):
	while true:
		var err = start_sem.wait()
		assert(err == OK)
		
		_load_one()

func _init():
	._init()
	
	var err = thread.start(self, "_loop")
	assert(err == OK)