extends Spatial
class_name SimStation

# Just to speed-up lookup
var market_resource = {}

func _ready():
	for child in get_children():
		if child is SimMarketResource:
			market_resource[child.resource_type] = child

func store_resource(resource_type, quantity):
	if not market_resource.has(resource_type):
		return 0
	
	var res: SimMarketResource = market_resource[resource_type]
	var space_left = res.capacity - res.quantity
	var to_store = clamp(quantity, 0, space_left)
	res.quantity += to_store
	return to_store

func retrieve_resource(resource_type, quantity):
	if not market_resource.has(resource_type):
		return 0
	
	var res: SimMarketResource = market_resource[resource_type]
	var to_retrieve = clamp(quantity, 0, res.quantity)
	res.quantity -= to_retrieve
	return to_retrieve
