extends "../Location.gd"
class_name AsteroidField

export(float, 0, 1000) var max_resources_per_asteroid = 100
export(float, 0, 1000) var max_asteroid_count = 128
export(float, -2, 2) var angular_mean = 0.0
export(float, 0, 2) var angular_deviation = 0.15
export(float, 25.0, 500.0) var min_separation = 100.0

var resources = {}

func _ready():
	spatial_scene_uri = "res://scenes/Asteroid/AsteroidField.tscn"
	for child in $Resources.get_children():
		resources[child.resource_type] = child

func load_spatial_instance() -> Spatial:
	var res: Spatial = instance_spatial_scene()
	res.dual = self
	return res

func distribute_resources():
	# Compute occurence (using prices)
	var occurence = {}
	var total = 0.0
	for resource_type in resources.keys():
		var price = float(Constants.RESOURCE_BASE_PRICE[resource_type])
		var quantity = resources[resource_type].quantity
		var rate = price * quantity
		
		occurence[resource_type] = {
			"rate": rate,
			"left": quantity,
			"price": price
		}
		total += rate
	
	var asteroids = []
	while len(asteroids) < max_asteroid_count and total > 0:
		var dice = rand_range(0.0, total)
		var resource_type = null
		for key in occurence.keys():
			var rate = occurence[key]["rate"]
			dice -= rate
			if dice <= 0:
				resource_type = key
				break
		assert(resource_type != null)
		
		var entry = occurence[resource_type]
		var quantity: int = entry["left"]
		quantity = int(min(max_resources_per_asteroid, quantity))
		entry["left"] -= quantity 
		entry["rate"] -= quantity * entry["price"]
		total -= quantity * entry["price"]
		
		asteroids.append({
			"resource_type": resource_type,
			"quantity": quantity,
		})
	return asteroids

func consume_resources(resource_type: int, quantity: int):
	print("consume ", resource_type, quantity)
	resources[resource_type].consume_resources(quantity)
