extends Area
class_name Location

var spatial_scene_uri = ""

func get_location_name():
	return name

func _on_InteractiveLoader_area_entered(_area):
	pass
	# TODO(indutny): use https://docs.godotengine.org/en/latest/classes/class_resourceloader.html#class-resourceloader-method-load-threaded-get
	# once it is out
	# ResourceQueue.queue_resource(spatial_scene_uri)
	
func _on_InteractiveLoader_area_exited(_area):
	pass
	# ResourceQueue.cancel_resource(spatial_scene_uri)

func instance_spatial_scene() -> Spatial:
	return load(spatial_scene_uri).instance()
	# return ResourceQueue.get_resource(spatial_scene_uri).instance()
