extends ScrollContainer

signal transaction

const HUDStationBuilding = preload("res://scenes/HUD/StationBuilding.tscn")

var current_player: Player
var station: Station

var buildings = []

func set_player(player: Player):
	current_player = player
	station = player.station
	
	for child in $List.get_children():
		$List.remove_child(child)
	
	for building in station.buildings:
		var ui = HUDStationBuilding.instance()
		ui.init(current_player, building)
		ui.connect("update_building", self, "_on_building_update")
		
		buildings.append(ui)
		$List.add_child(ui)
	
	update_market()
	
func update_market():
	for ui in buildings:
		ui.update()

func _on_building_update(_building):
	emit_signal("transaction")
