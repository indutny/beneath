extends Node

var stations = {}

func _ready():
	stations[0] = SimStation.new()
	stations[0].station_name = "Alpha"
	stations[0].buy_price[Constants.ResourceType.Metal] = 11
	
	stations[1] = SimStation.new()
	stations[1].station_name = "Beta"
	stations[1].buy_price[Constants.ResourceType.Metal] = 15

func _process(delta):
	pass
