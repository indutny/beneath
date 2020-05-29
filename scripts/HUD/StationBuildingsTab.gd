extends ScrollContainer

const HUDStationBuilding = preload("res://scenes/HUD/StationBuilding.tscn")

var current_player: Player
var station: Station

func set_player(player: Player):
	current_player = player
	station = player.current_station
	
	for child in $List.get_children():
		$List.remove_child(child)
	
	for building in station.buildings:
		var item = HUDStationBuilding.instance()
		item.set_building(building)
		$List.add_child(item)
