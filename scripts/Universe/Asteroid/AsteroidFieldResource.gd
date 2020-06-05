extends Node

export(Constants.ResourceType) var resource_type = Constants.ResourceType.Ice
export(int, 0, 10000) var capacity = 100

var last_replenish_tick: int = 0
var quantity = capacity

func serialize():
	return {
		"quantity": quantity,
		"last_replenish_tick": last_replenish_tick,
	}

func deserialize(dict):
	quantity = int(dict["quantity"])
	last_replenish_tick = int(dict["last_replenish_tick"])

func process_tick(tick):
	var replenish_interval = \
		Constants.ASTEROID_REPLENISH_INTERVAL[resource_type]
	
	# Depletes once and forever
	if replenish_interval == 0.0:
		return
	
	if tick > last_replenish_tick + replenish_interval:
		last_replenish_tick = tick
		quantity = int(min(quantity + 1, capacity))

func consume_resources(amount: int):
	quantity -= amount
