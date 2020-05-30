extends ScrollContainer

signal transaction

const HUDStationBuilding = preload("res://scenes/HUD/StationBuilding.tscn")

var current_player: Player
var station: Station

func set_player(player: Player):
	current_player = player
	station = player.station
	update_market()
	
func update_market():
	for child in $List.get_children():
		$List.remove_child(child)
	
	for building in station.buildings:
		var item = HUDStationBuilding.instance()
		item.init(current_player, building)
		item.connect("update_building", self, "_on_building_update")
		$List.add_child(item)

func _on_building_update(_building):
	emit_signal("transaction")
