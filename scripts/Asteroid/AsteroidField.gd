extends Spatial

var dual: AsteroidField

var Asteroid = preload("res://scenes/Asteroid/Asteroid.tscn")

func is_overlapping(list: Array, origin: Vector3, min_separation: float):
	for entry in list:
		if origin.distance_to(entry) < min_separation:
			return true
	return false

func set_player_pos(player_pos: Vector3):
	var added = []
	for config in dual.distribute_resources():
		var node: SpatialAsteroid = Asteroid.instance()
		
		var origin = Vector3()
		origin.y = Utils.random_normal(0.0, dual.min_separation)
		
		# Leave enough space for player
		while origin.distance_to(player_pos) < 50.0 or \
			is_overlapping(added, origin, dual.min_separation):
			origin.x = Utils.random_normal(0.0, 1000.0)
			origin.z = Utils.random_normal(0.0, 1000.0)
		node.transform.origin = origin
		
		node.angular_velocity.x = Utils.random_normal(
			dual.angular_mean, dual.angular_deviation)
		node.angular_velocity.y = Utils.random_normal(
			dual.angular_mean, dual.angular_deviation)
		node.angular_velocity.z = Utils.random_normal(
			dual.angular_mean, dual.angular_deviation)
		
		node.configure(config)
		add_child(node)
		added.append(node.transform.origin)
		
		var err = node.connect(
			"resources_taken", self, "_on_Asteroid_resources_taken")
		assert(err == OK)
		
func _on_Asteroid_resources_taken(resource_type: int, quantity: int):
	dual.consume_resources(resource_type, quantity)
