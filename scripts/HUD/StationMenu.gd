extends MarginContainer

signal undock

var current_player

func set_player(player: Player):
	current_player = player
	
	$TabContainer/Sell.set_player(player)
	$TabContainer/Buy.set_player(player)
	$TabContainer/Buildings.set_player(player)


func _on_Undock_pressed():
	emit_signal("undock")


func _on_any_transaction():
	$TabContainer/Buy.update_market()
	$TabContainer/Sell.update_market()
	$TabContainer/Buildings.update_market()
