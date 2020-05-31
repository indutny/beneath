extends Spatial
class_name AsteroidField

export(Constants.ResourceType) var resource_type = \
	Constants.ResourceType.Ice
export(float, 0, 1000) var resource_mean = 100
export(float, 0, 1000) var resource_deviation = 50
export(float, 0, 1000) var asteroid_count = 10
export(float, -2, 2) var angular_mean = 0.0
export(float, 0, 2) var angular_deviation = 0.15

func load_spatial_instance() -> Spatial:
	var res: Spatial = \
		load("res://scenes/Asteroid/AsteroidField.tscn").instance() as Spatial
	res.set_dual(self)
	return res
