extends Node
class_name StationBuilding

export(Constants.BuildingType) var building_type = \
	Constants.BuildingType.Vacant
export(int) var level = 0
var last_production_tick = 0

func serialize():
	return {
		"building_type": building_type,
		"level": level,
		"last_production_tick": last_production_tick
	}

func deserialize(data):
	building_type = int(data["building_type"])
	level = int(data["level"])
	last_production_tick = int(data["last_production_tick"])

func get_produce_dict() -> Dictionary:
	return Constants.BUILDING_PRODUCES[building_type]

func get_consume_dict() -> Dictionary:
	return Constants.BUILDING_CONSUMES[building_type]

# TODO(indutny): building upgrades
func get_produce_interval() -> float:
	return Constants.BUILDING_PRODUCE_INTERVAL[building_type][level]

func produce(tick, station) -> bool:
	if get_produce_interval() + last_production_tick > tick:
		return false
	last_production_tick = tick
	
	# Has enough input resources
	var consumes = get_consume_dict()
	for resource_type in consumes.keys():
		var quantity = consumes[resource_type]
		if not station.has_resource(resource_type, quantity):
			return false
	
	# Has enough room for output resources
	var produces = get_produce_dict()
	for resource_type in produces.keys():
		var quantity = produces[resource_type]
		if not station.can_store_resource(resource_type, quantity):
			return false
	
	for resource_type in consumes.keys():
		var quantity = consumes[resource_type]
		var got = station.retrieve_resource(resource_type, quantity)
		assert(got == quantity)
	
	for resource_type in produces.keys():
		var quantity = produces[resource_type]
		var stored = station.store_resource(resource_type, quantity)
		assert(stored == quantity)
	
	return true
