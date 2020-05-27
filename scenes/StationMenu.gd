extends MarginContainer

signal undock

var current_player = null
var current_station = null

var SellResourceItem = preload("res://scenes/SellResourceItem.tscn")

func set_player(player):
	current_player = player
	current_station = current_player.current_station
	$TabContainer/Station/Name.text = current_station.station_name
	
	reset_sell_tab()

func reset_sell_tab():
	# Clear
	for child in $TabContainer/Sell/Scroll/List.get_children():
		$TabContainer/Sell/Scroll/List.remove_child(child)
	
	# Add new children
	var cargo = current_player.cargo
	for resource_type in cargo:
		var item = SellResourceItem.instance()
		item.set_resource(resource_type, cargo[resource_type], 10)
		$TabContainer/Sell/Scroll/List.add_child(item)

func _on_Undock_pressed():
	emit_signal("undock")


func _on_Sell_pressed():
	for child in $TabContainer/Sell/Scroll/List.get_children():
		var sold = current_player.remove_cargo(
			child.resource_type, child.quantity)
		current_player.add_credits(sold * 10)
	reset_sell_tab()
