extends "./Location.gd"
class_name AsteroidField

export(Constants.ResourceType) var resource_type = \
	Constants.ResourceType.Ice
export(float, 0, 1000) var resource_mean = 100
export(float, 0, 1000) var resource_deviation = 50
export(float, 0, 1000) var asteroid_count = 128
export(float, -2, 2) var angular_mean = 0.0
export(float, 0, 2) var angular_deviation = 0.15
export(float, 25.0, 500.0) var min_separation = 100.0

func _ready():
	spatial_scene_uri = "res://scenes/Asteroid/AsteroidField.tscn"

func load_spatial_instance(player_pos: Vector3) -> Spatial:
	var res: Spatial = instance_spatial_scene()
	res.configure(self, player_pos)
	return res
