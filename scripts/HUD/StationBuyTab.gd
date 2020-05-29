extends VBoxContainer

signal transaction

const HUDMarketResource = preload("res://scenes/HUD/MarketResource.tscn")

var current_player: Player
var station: Station

func set_player(player: Player):
	current_player = player
	station = player.current_station
	
	reset()

func reset():
	# Clear
	for child in $Scroll/List.get_children():
		$Scroll/List.remove_child(child)
	
	# Add new children
	for resource_type in station.market_resource:
		var res = station.market_resource[resource_type]
		var item = HUDMarketResource.instance()
		item.set_resource(
			res, res.quantity, station.get_buy_price(resource_type))
		$Scroll/List.add_child(item)


# TODO(indutny): DRY
func _on_Confirm_pressed():
	for child in $Scroll/List.get_children():
		var res = child.resource
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
	
	emit_signal("transaction")
