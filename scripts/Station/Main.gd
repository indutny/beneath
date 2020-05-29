extends StaticBody
class_name Station

export(float, 0, 10) var max_docking_velocity = 0.2
export(float, 0, 20) var platform_width = 10.0
export(float, 0, 3) var orientation_tolerance = PI / 8.0
export(float, 0, 3) var angle_tolerance = PI / 12.0
export(int, 0, 100000) var resource_capacity = 1000

var dock

# Just to speed-up lookup
var market_resource = {}
var buildings = []

func _ready():
	dock = $OpenDock
	for child in get_children():
		if child is StationBuilding:
			buildings.append(child)
	
	for resource_type in Constants.ResourceType.values():
		market_resource[resource_type] = {
			"resource_type": resource_type,
			"quantity": 0,
			"capacity": resource_capacity
		}

func store_resource(resource_type, quantity):	
	var res = market_resource[resource_type]
	var space_left = res.capacity - res.quantity
	var to_store = clamp(quantity, 0, space_left)
	res.quantity += to_store
	return to_store

func get_touchdown_position() -> Node:
	return $OpenDock/Center

func retrieve_resource(resource_type, quantity):	
	var res = market_resource[resource_type]
	var to_retrieve = clamp(quantity, 0, res.quantity)
	res.quantity -= to_retrieve
	return to_retrieve

func get_resource_economics(resource_type):
	var price = Constants.RESOURCE_BASE_PRICE[resource_type]
	var resource = market_resource[resource_type]
	var supply = 0
	var demand = 0.0
	for building in buildings:
		var interval = building.get_produce_interval()
		
		var produces = building.get_produce_dict()
		var consumes = building.get_consume_dict()
		supply += produces.get(resource_type, 0) / interval
		demand += consumes.get(resource_type, 0) / interval
	return price

func get_buy_price(resource_type):
	var price = Constants.RESOURCE_BASE_PRICE[resource_type]
	var eco = get_resource_economics(resource_type)
	return price

func get_sell_price(resource_type):
	var price = Constants.RESOURCE_BASE_PRICE[resource_type]
	return price
