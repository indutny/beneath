extends Node
class_name StationBuilding

# TODO(indutny): persist these
export(Constants.BuildingType) var building_type = \
	Constants.BuildingType.Vacant
export(int) var level = 0
export(int) var last_production_tick = 0

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
	
	# Has enough input resources
	var consumes = get_consume_dict()
	for resource_type in consumes:
		var quantity = consumes[resource_type]
		if not station.has_resource(resource_type, quantity):
			return false
	
	# Has enough room for output resources
	var produces = get_produce_dict()
	for resource_type in produces:
		var quantity = produces[resource_type]
		if not station.can_store_resource(resource_type, quantity):
			return false
	
	for resource_type in consumes:
		var quantity = consumes[resource_type]
		var got = station.retrieve_resource(resource_type, quantity)
		assert(got == quantity)
	
	for resource_type in produces:
		var quantity = produces[resource_type]
		var stored = station.store_resource(resource_type, quantity)
		assert(stored == quantity)
	
	last_production_tick = tick
	return true
