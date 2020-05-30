class_name MarketResource

var resource_type
var quantity: int = 0
var capacity: int

func _init(resource_type_: int, capacity_: int):
	resource_type = resource_type_
	capacity = capacity_

func serialize():
	return {
		"quantity": quantity,
		"capacity": capacity
	}

func deserialize(data):
	quantity = int(data["quantity"])
	capacity = int(data["capacity"])

func store(num: int):
	var to_store = clamp(num, 0, capacity - quantity)
	quantity += to_store
	return to_store

func retrieve(num: int):
	var to_retrieve = clamp(num, 0, quantity)
	quantity -= to_retrieve
	return to_retrieve
