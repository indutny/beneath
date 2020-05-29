extends MarginContainer

signal undock

var player: Player
var station: Station

func set_player(player_: Player):
	if station:
		station.disconnect("production_update", self, "_on_any_transaction")

	player = player_
	station = player.current_station
	var err = station.connect("production_update", self, "_on_any_transaction")
	assert(err == OK)
	
	$TabContainer/Station/Name.text = station.name
	$TabContainer/Sell.set_player(player)
	$TabContainer/Buy.set_player(player)
	$TabContainer/Buildings.set_player(player)


func _on_Undock_pressed():
	emit_signal("undock")


func _on_any_transaction():
	$TabContainer/Buy.update_market()
	$TabContainer/Sell.update_market()
	$TabContainer/Buildings.update_market()
