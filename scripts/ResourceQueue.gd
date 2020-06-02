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
	_check(err == OK)

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
		
		if result:
			return result
		
		start_mutex.lock()
		var is_running = running.has(uri)
		start_mutex.unlock()
		if not is_running:
			queue_resource(uri)
		
		var err = complete_sem.wait()
		_check(err == OK)
	return null

func stop():
	var err = start_sem.post()
	_check(err == OK)
	
	thread.wait_to_finish()
	
func _load_one():
	start_mutex.lock()
	var uri = queue.pop_front()
	start_mutex.unlock()
	
	if not uri:
		return false
	
	var loader: ResourceInteractiveLoader = \
		ResourceLoader.load_interactive(uri)
	start_mutex.lock()
	running[uri] = loader
	start_mutex.unlock()
	
	var err = loader.wait()
	_check(err == ERR_FILE_EOF)
	
	start_mutex.lock()
	running.erase(uri)
	start_mutex.unlock()
	
	complete_mutex.lock()
	complete[uri] = loader.get_resource()
	complete_mutex.unlock()
	
	err = complete_sem.post()
	_check(err == OK)
	
	return true
	
func _loop(_data):
	while true:
		var err = start_sem.wait()
		_check(err == OK)
		
		if not _load_one():
			break

func _check(condition):
	if condition:
		return
	print_debug("ResourceQueue check failed")
	assert(0)

func _init():
	._init()
	
	var err = thread.start(self, "_loop")
	_check(err == OK)
