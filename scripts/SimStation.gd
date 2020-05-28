extends Node
class_name SimStation

var station_name = ""
var buy_price = {}
var sell_price = {}
var resources = {}

func add_resource(resource_type, quantity):
	resources[resource_type] = resources.get(resource_type, 0) + \
		max(0, quantity)
