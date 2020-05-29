extends Node
class_name StationBuilding

export(Constants.BuildingType) var building_type = \
	Constants.BuildingType.Vacant
export(int) var level = 0

func get_produce_dict() -> Dictionary:
	return Constants.BUILDING_PRODUCES[building_type]

func get_consume_dict() -> Dictionary:
	return Constants.BUILDING_CONSUMES[building_type]

# TODO(indutny): building upgrades
func get_produce_interval() -> float:
	return Constants.BUILDING_PRODUCE_INTERVAL[building_type][level]
