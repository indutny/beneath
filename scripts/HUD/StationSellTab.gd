extends VBoxContainer

signal transaction

var player: Player
var station: Station

func set_player(player_: Player):
	player = player_
	station = player.station
	reset()

func reset():
	$List.reset()
	update_market()

func update_market():
	var cargo = player.cargo
	for resource_type in station.resources.keys():
		var station_capacity = \
			Constants.RESOURCE_STATION_CAPACITY[resource_type]
		var station_quantity = station.resources[resource_type]
		var ui = $List.get_resource(resource_type)
		
		var quantity = cargo.get(resource_type, 0)
		ui.visible = quantity != 0
		
		var max_sell_quantity = min(
			quantity,
			station_capacity - station_quantity)
		ui.configure(max_sell_quantity, station.get_sell_price(resource_type))

func _on_Confirm_pressed():
	var cargo = player.cargo
	for resource_type in cargo.keys():
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
