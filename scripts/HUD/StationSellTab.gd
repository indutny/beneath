extends VBoxContainer

signal transaction

var player: Player
var station: Station

func set_player(player_):
	player = player_
	station = player.current_station
	reset()

func reset():
	$List.reset()
	update_market()

func update_market():
	var cargo = player.cargo
	for resource_type in station.market_resource:
		var market_resource = station.market_resource[resource_type]
		var ui = $List.get_resource(resource_type)
		
		var quantity = cargo.get(resource_type, 0)
		ui.visible = quantity != 0
		
		var max_sell_quantity = min(
			quantity,
			market_resource.capacity - market_resource.quantity)
		ui.configure(max_sell_quantity, station.get_sell_price(resource_type))

func _on_Confirm_pressed():
	var cargo = player.cargo
	for resource_type in cargo:
		var ui = $List.get_resource(resource_type)
		
		var to_sell = player.retrieve_cargo(resource_type, ui.get_quantity())
		var stored = station.store_resource(resource_type, to_sell)
		
		# Return rest back to player
		if stored != to_sell:
			var to_return = max(to_sell - stored, 0)
			var returned = player.store_cargo(resource_type, to_return)
			assert(returned == to_return)
		
		player.add_credits(stored * ui.get_price())
		ui.reset()
	
	emit_signal("transaction")
