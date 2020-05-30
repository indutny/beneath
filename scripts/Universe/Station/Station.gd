extends Spatial
class_name Station

signal production_update

export(int, 0, 100000) var resource_capacity = 1000

# Just to speed-up lookup
var market_resource = {}
var buildings = []

func _ready():
	for child in get_children():
		if child is StationBuilding:
			buildings.append(child)
	
	for resource_type in Constants.ResourceType.values():
		var resource = MarketResource.new(resource_type, resource_capacity)
		market_resource[resource_type] = resource

#
# Persistence
#

func serialize():
	var market = {}
	for resource_type in market_resource.keys():
		market[resource_type] = market_resource[resource_type].serialize()
	return { "market": market }

func deserialize(data):
	var market = data["market"]
	for resource_type in market.keys():
		var subdata = market[resource_type]
		market_resource[int(resource_type)].deserialize(subdata)

#
# Visual Instancing
#

func load_visual_instance() -> Spatial:
	var res: Spatial = \
		load("res://scenes/Station/Station.tscn").instance() as Spatial
	res.transform.basis = transform.basis
	res.dual = self
	return res

#
# Storage and Market
#

func store_resource(resource_type, quantity):
	var res = market_resource[resource_type]
	var space_left = res.capacity - res.quantity
	var to_store = clamp(quantity, 0, space_left)
	res.quantity += to_store
	return to_store

func has_resource(resource_type, quantity) -> bool:
	return market_resource[resource_type].quantity >= quantity

func can_store_resource(resource_type, quantity) -> bool:
	var market = market_resource[resource_type]
	return quantity <= market.capacity - market.quantity

func retrieve_resource(resource_type, quantity):
	var res = market_resource[resource_type]
	var to_retrieve = clamp(quantity, 0, res.quantity)
	res.quantity -= to_retrieve
	return to_retrieve

func get_resource_economics(resource_type):
	var price = Constants.RESOURCE_BASE_PRICE[resource_type]
	var supply = 0
	var demand = 0.0
	for building in buildings:
		var interval = building.get_produce_interval()
		
		var produces = building.get_produce_dict()
		var consumes = building.get_consume_dict()
		supply += produces.get(resource_type, 0) / interval
		demand += consumes.get(resource_type, 0) / interval
	var adjusted_price = price * pow(20.0, demand - supply)
	
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
	if produced:
		emit_signal("production_update")
