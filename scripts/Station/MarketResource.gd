extends Node
class_name MarketResource

signal quantity_changed(new_value)

export(Constants.ResourceType) var resource_type
export(int) var quantity = 0
export(int) var capacity = 1000

func serialize():
	return {
		"quantity": quantity,
		"capacity": capacity
	}

func deserialize(data):
	quantity = int(data["quantity"])
	capacity = int(data["capacity"])

func set_resource_type(resource_type_):
	resource_type = resource_type_

func set_capacity(capacity_: int):
	capacity = capacity_

func store(num: int):
	var to_store = clamp(num, 0, capacity - quantity)
	quantity += to_store
	emit_signal("quantity_changed", quantity)
	return to_store

func retrieve(num: int):
	var to_retrieve = clamp(num, 0, quantity)
	quantity -= to_retrieve
	emit_signal("quantity_changed", quantity)
	return to_retrieve
