extends Area
class_name Location

var spatial_scene_uri = ""

func _on_InteractiveLoader_area_entered(_area):
	ResourceQueue.queue_resource(spatial_scene_uri)
	
func _on_InteractiveLoader_area_exited(_area):
	ResourceQueue.cancel_resource(spatial_scene_uri)

func instance_spatial_scene() -> Spatial:
	return ResourceQueue.get_resource(spatial_scene_uri).instance()
