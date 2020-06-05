extends RigidBody
class_name SpatialAsteroid

signal resources_taken(resource_type, quantity)

var resource_type: int
var resources: int = 0

func configure(config):
	resource_type = config["resource_type"]
	resources = config["quantity"]

func take_resources(quantity: int) -> int:
	var to_take: int = int(clamp(quantity, 0, resources))
	resources -= to_take
	
	emit_signal("resources_taken", resource_type, to_take)
	
	return to_take
