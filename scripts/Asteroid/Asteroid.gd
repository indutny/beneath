extends RigidBody
class_name SpatialAsteroid

var resource_type
var resources = 0

func configure(field: AsteroidField):
	resource_type = field.resource_type
	resources = max(0, Utils.random_normal(field.resource_mean, \
		field.resource_deviation))
