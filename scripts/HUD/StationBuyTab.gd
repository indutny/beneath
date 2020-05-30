extends VBoxContainer

signal transaction

var player: Player
var station: Station

func set_player(player_):
	player = player_
	station = player.station
	reset()

func reset():
	$List.reset()
	update_market()

func update_market():
	for resource_type in station.market_resource:
		var market_resource = station.market_resource[resource_type]
		var ui = $List.get_resource(resource_type)
	
		ui.visible = market_resource.quantity != 0
		
		var buy_price = station.get_buy_price(resource_type)
		var max_buy_quantity = min(
			floor(player.credits / buy_price),
			market_resource.quantity)
		ui.configure(max_buy_quantity, buy_price, market_resource.quantity)

# TODO(indutny): DRY
func _on_Confirm_pressed():
	for resource_type in station.market_resource:
		var ui = $List.get_resource(resource_type)
		
		var to_buy = station.retrieve_resource(
			resource_type, ui.get_quantity())
			
		# Check that player has enough credits
		if not player.spend_credits(to_buy * ui.get_price()):
			continue
		
		var stored = player.store_cargo(resource_type, to_buy)
			
		# Refund
		if stored != to_buy:
			var excess = max(to_buy - stored, 0)
			player.add_credits(excess * ui.get_price())
			station.store_resource(resource_type, excess)
		
		ui.reset()
	
	emit_signal("transaction")
