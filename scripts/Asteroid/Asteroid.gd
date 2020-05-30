extends RigidBody
class_name Asteroid

export(Constants.ResourceType) var resource_type = \
	Constants.ResourceType.IronOre
export(float, 0, 1000) var max_resources = 100
export(float, 0, 10) var replenish_speed = 0.1

var resources = max_resources

func _process(delta):
	resources = min(max_resources, resources + delta * replenish_speed)

func serialize():
	return {
		"resources": resources
	}

func deserialize(data):
	resources = float(data["resources"])
