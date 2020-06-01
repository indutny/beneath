extends Area
class_name Location

var spatial_scene_uri = ""

func _on_InteractiveLoader_area_entered(_area):
	# TODO(indutny): use https://docs.godotengine.org/en/latest/classes/class_resourceloader.html#class-resourceloader-method-load-threaded-get
	# once it is out
	ResourceQueue.queue_resource(spatial_scene_uri)
	
func _on_InteractiveLoader_area_exited(_area):
	ResourceQueue.cancel_resource(spatial_scene_uri)

func instance_spatial_scene() -> Spatial:
	return ResourceQueue.get_resource(spatial_scene_uri).instance()
