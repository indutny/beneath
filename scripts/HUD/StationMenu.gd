extends MarginContainer

signal undock

var current_player
var station: Station

const HUDMarketResource = preload("res://scenes/HUD/MarketResource.tscn")

func set_player(player: Player):
	current_player = player
	station = player.current_station
	$TabContainer/Station/Name.text = station.name
	
	reset_sell_tab()
	reset_buy_tab()

func reset_sell_tab():
	# Clear
	for child in $TabContainer/Sell/Scroll/List.get_children():
		$TabContainer/Sell/Scroll/List.remove_child(child)
	
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
		$TabContainer/Sell/Scroll/List.add_child(item)

func reset_buy_tab():
	# Clear
	for child in $TabContainer/Buy/Scroll/List.get_children():
		$TabContainer/Buy/Scroll/List.remove_child(child)
	
	# Add new children
	for resource_type in station.market_resource:
		var res: MarketResource = station.market_resource.get(resource_type)
		var item = HUDMarketResource.instance()
		item.set_resource(res, res.quantity, res.buy_price)
		$TabContainer/Buy/Scroll/List.add_child(item)

func _on_Undock_pressed():
	emit_signal("undock")


func _on_Sell_pressed():
	for child in $TabContainer/Sell/Scroll/List.get_children():
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
	
	reset_sell_tab()
	reset_buy_tab()

# TODO(indutny): DRY
func _on_Buy_pressed():
	for child in $TabContainer/Buy/Scroll/List.get_children():
		var res: MarketResource = child.resource
		var to_buy = station.retrieve_resource(
			res.resource_type, child.get_quantity())
			
		# Check that player has enough credits
		if not current_player.spend_credits(to_buy * child.price):
			continue
		
		var stored = current_player.store_cargo(
			res.resource_type, to_buy)
			
		# Refund
		if stored != to_buy:
			var excess = max(to_buy - stored, 0)
			current_player.add_credits(excess * child.price)
			station.store_resource(res.resource_type, excess)
	
	reset_buy_tab()
	reset_sell_tab()
