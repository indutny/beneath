extends VBoxContainer

signal transaction

const HUDMarketResource = preload("res://scenes/HUD/MarketResource.tscn")

var current_player: Player
var station: Station

func set_player(player):
	current_player = player
	station = player.current_station
	reset()

func reset():
	# Clear
	for child in $Scroll/List.get_children():
		$Scroll/List.remove_child(child)
	
	# Add new children
	var cargo = current_player.cargo
	for resource_type in cargo:
		var res: MarketResource = station.market_resource.get(resource_type)
		if not res:
			continue
			
		var item = HUDMarketResource.instance()
		item.set_resource(
			res,
			min(cargo[resource_type], res.capacity - res.quantity),
			res.sell_price)
		$Scroll/List.add_child(item)


func _on_Confirm_pressed():
	for child in $Scroll/List.get_children():
		var res: MarketResource = child.resource
		var to_sell = current_player.retrieve_cargo(
			res.resource_type, child.get_quantity())
		var stored = station.store_resource(res.resource_type, to_sell)
		
		# Return rest back to player
		if stored != to_sell:
			var to_return = max(to_sell - stored, 0)
			var returned = current_player.store_cargo(
				res.resource_type, to_return)
			assert(returned == to_return)
		
		current_player.add_credits(stored * child.price)
	
	emit_signal("transaction")
