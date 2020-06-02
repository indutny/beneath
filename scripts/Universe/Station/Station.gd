extends "../Location.gd"
class_name Station

signal production_update

export(int, 0, 100000) var resource_capacity = 1000

var last_refuel_tick: int = 0

# Just to speed-up lookup
var resources = {}
var buildings = []

func _ready():
	spatial_scene_uri = "res://scenes/Station/Station.tscn"
	for child in get_children():
		if child is StationBuilding:
			buildings.append(child)
	
	for resource_type in Constants.ResourceType.values():
		resources[resource_type] = 0

#
# Persistence
#

func serialize():
	return { "resources": resources, "last_refuel_tick": last_refuel_tick }

func deserialize(data):
	var saved = data["resources"]
	for resource_type in saved.keys():
		var quantity = saved[resource_type]
		resources[int(resource_type)] = int(quantity)
	last_refuel_tick = data.get("last_refuel_tick", 0)

#
# Visual Instancing
#

func load_spatial_instance() -> Spatial:
	var instance = instance_spatial_scene()
	instance.dual = self
	return instance

#
# Storage and Market
#

func store_resource(resource_type: int, quantity: int):
	var stored = resources[resource_type]
	var capacity = Constants.RESOURCE_STATION_CAPACITY[resource_type]
	var space_left = capacity - stored
	var to_store = clamp(quantity, 0, space_left)
	resources[resource_type] += to_store
	return to_store

func has_resource(resource_type: int, quantity: int) -> bool:
	return resources[resource_type] >= quantity

func can_store_resource(resource_type, quantity) -> bool:
	var stored = resources[resource_type]
	return quantity <= Constants.RESOURCE_STATION_CAPACITY[resource_type] - \
		stored

func retrieve_resource(resource_type, quantity):
	var stored = resources[resource_type]
	var to_retrieve = clamp(quantity, 0, stored)
	resources[resource_type] -= to_retrieve
	return to_retrieve

func has_resources(dict: Dictionary) -> bool:
	for key in dict.keys():
		if not has_resource(key, dict[key]):
			return false
	return true

func retrieve_resources(dict: Dictionary) -> Dictionary:
	var out = {}
	for key in dict.keys():
		out[key] = retrieve_resource(key, dict[key])
	return out

func get_resource_economics(resource_type):
	var price = Constants.RESOURCE_BASE_PRICE[resource_type]
	
	# No calculation and no mark-up for priceless resources
	if price == 0:
		return { "buy_price": 0, "sell_price": 0 }
	
	var supply = 0
	var demand = 0.0
	for building in buildings:
		var interval = building.get_produce_interval()
		
		var produces = building.get_produce_dict()
		var consumes = building.get_consume_dict()
		supply += produces.get(resource_type, 0) / interval
		demand += consumes.get(resource_type, 0) / interval
	var adjusted_price = price * pow(5.0, demand - supply)
	
	return {
		"buy_price": convert(max(
			ceil(adjusted_price * Constants.MARK_UP), 1), TYPE_INT),
		"sell_price": convert(max(floor(adjusted_price), 1), TYPE_INT)
	}

func get_buy_price(resource_type) -> int:
	var economics = get_resource_economics(resource_type)
	return economics["buy_price"]

func get_sell_price(resource_type) -> int:
	var economics = get_resource_economics(resource_type)
	return economics["sell_price"]

# NOTE: Called by Universe
func process_tick(tick):
	var produced = false
	for building in buildings:
		if building.produce(tick, self):
			produced = true
	
	if tick > last_refuel_tick + Constants.STATION_REFUEL_INTERVAL:
		last_refuel_tick = tick
		store_resource(Constants.ResourceType.Fuel, 1)
		
	if produced:
		emit_signal("production_update")
