extends Node

export(Constants.ResourceType) var resource_type = Constants.ResourceType.Ice;
export(int, 0, 10000) var quantity = 1000;

func serialize():
	return { "resource_type": resource_type, "quantity": quantity }

func deserialize(dict):
	resource_type = int(dict["resource_type"])
	quantity = int(dict["quantity"])

func process_tick(_tick):
	pass
