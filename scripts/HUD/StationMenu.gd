extends MarginContainer

signal take_off

var player: Player
var station: Station

func set_player(player_: Player):
	if station:
		station.disconnect("production_update", self, "_on_any_transaction")

	player = player_
	station = player.station
	var err = station.connect("production_update", self, "_on_any_transaction")
	assert(err == OK)
	
	$TabContainer/Station/Name.text = station.name
	$TabContainer/Sell.set_player(player)
	$TabContainer/Buy.set_player(player)
	$TabContainer/Buildings.set_player(player)

func _on_any_transaction():
	$TabContainer/Buy.update_market()
	$TabContainer/Sell.update_market()
	$TabContainer/Buildings.update_market()


func _on_TakeOff_pressed():
	emit_signal("take_off")
