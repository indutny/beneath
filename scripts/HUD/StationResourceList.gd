extends Node

const HUDMarketResource = preload("res://scenes/HUD/MarketResource.tscn")

var resources = {}

func _ready():
	for resource_type in Constants.ResourceType.values():
		var item = HUDMarketResource.instance()
		item.set_resource_type(resource_type)
		$List.add_child(item)
		resources[resource_type] = item

func reset():
	for resource in resources.values():
		resource.reset()

func get_resource(resource_type):
	return resources[resource_type]
