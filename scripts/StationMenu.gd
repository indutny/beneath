extends MarginContainer

signal undock

var current_player = null
var current_station: SimStation

const ShopItem = preload("res://scenes/ShopItem.tscn")

func set_player(player):
	current_player = player
	current_station = Simulation.stations.get(
		current_player.current_station.station_id)
	$TabContainer/Station/Name.text = current_station.station_name
	
	reset_sell_tab()
	reset_buy_tab()

func reset_sell_tab():
	# Clear
	for child in $TabContainer/Sell/Scroll/List.get_children():
		$TabContainer/Sell/Scroll/List.remove_child(child)
	
	# Add new children
	var cargo = current_player.cargo
	for resource_type in cargo:
		if not current_station.buy_price.has(resource_type):
			continue
		
		var item = ShopItem.instance()
		item.set_resource(
			resource_type,
			cargo[resource_type],
			current_station.buy_price[resource_type])
		$TabContainer/Sell/Scroll/List.add_child(item)

func _on_Undock_pressed():
	emit_signal("undock")


func _on_Sell_pressed():
	for child in $TabContainer/Sell/Scroll/List.get_children():
		var sold = current_player.remove_cargo(
			child.resource_type, child.quantity)
		current_station.add_resource(child.resource_type, sold)
		current_player.add_credits(
			sold * current_station.buy_price[child.resource_type])
	reset_sell_tab()

func reset_buy_tab():
	# Clear
	for child in $TabContainer/Buy/Scroll/List.get_children():
		$TabContainer/Buy/Scroll/List.remove_child(child)
	
	# Add new children
	for resource_type in current_station.resources:
		if not current_station.sell_price.has(resource_type):
			continue
		
		var item = ShopItem.instance()
		item.set_resource(
			resource_type,
			current_station.resources[resource_type],
			current_station.sell_price[resource_type])
		$TabContainer/Buy/Scroll/List.add_child(item)

func _on_Buy_pressed():
	reset_buy_tab()
