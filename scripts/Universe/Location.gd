extends Area
class_name Location

var spatial_scene_uri = ""

func get_location_name():
	return name

func _on_InteractiveLoader_area_entered(_area):
	pass
	
func _on_InteractiveLoader_area_exited(_area):
	pass

func instance_spatial_scene() -> Spatial:
	return load(spatial_scene_uri).instance()
