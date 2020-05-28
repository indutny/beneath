extends RigidBody
class_name Asteroid

export(Constants.ResourceType) var resource_type = Constants.ResourceType.Metal
export(float, 0, 1000) var max_resources = 100
export(float, 0, 1000) var replenish_speed = 1

var resources = max_resources

func _process(delta):
	resources = min(max_resources, resources + delta * replenish_speed)