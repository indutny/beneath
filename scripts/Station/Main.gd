extends StaticBody
class_name Station

export(float, 0, 10) var max_docking_velocity = 0.2
export(float, 0, 20) var platform_width = 10.0
export(float, 0, 3) var orientation_tolerance = PI / 8.0
export(float, 0, 3) var angle_tolerance = PI / 12.0

# Just to speed-up lookup
var market_resource = {}
var dock

func _ready():
	dock = $OpenDock
	for child in get_children():
		if child is MarketResource:
			market_resource[child.resource_type] = child

func store_resource(resource_type, quantity):
	if not market_resource.has(resource_type):
		return 0
	
	var res: MarketResource = market_resource[resource_type]
	var space_left = res.capacity - res.quantity
	var to_store = clamp(quantity, 0, space_left)
	res.quantity += to_store
	return to_store

func get_touchdown_position() -> Node:
	return $OpenDock/Center

func retrieve_resource(resource_type, quantity):
	if not market_resource.has(resource_type):
		return 0
	
	var res: MarketResource = market_resource[resource_type]
	var to_retrieve = clamp(quantity, 0, res.quantity)
	res.quantity -= to_retrieve
	return to_retrieve
	
