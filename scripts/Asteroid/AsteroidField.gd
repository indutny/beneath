extends Spatial

var dual: AsteroidField

var Asteroid = preload("res://scenes/Asteroid/Asteroid.tscn")

func set_dual(dual_: AsteroidField):
	dual = dual_
	
	for i in range(0, dual.asteroid_count):
		var node: SpatialAsteroid = Asteroid.instance()
		node.transform.origin.x = (2 * randf() - 1) * 1000.0
		node.transform.origin.y = Utils.random_normal(1, 1) * 100.0
		node.transform.origin.z = (2 * randf() - 1) * 1000.0
		
		node.angular_velocity.x = Utils.random_normal(
			dual.angular_mean, dual.angular_deviation)
		node.angular_velocity.y = Utils.random_normal(
			dual.angular_mean, dual.angular_deviation)
		node.angular_velocity.z = Utils.random_normal(
			dual.angular_mean, dual.angular_deviation)
		
		node.configure(dual)
		add_child(node)
