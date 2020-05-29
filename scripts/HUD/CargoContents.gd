extends PopupPanel

var CargoItem = preload("res://scenes/HUD/CargoItem.tscn")

var items = {}

func _ready():
	for resource_type in Constants.ResourceType.values():
		var item = CargoItem.instance()
		item.set_resource_type(resource_type)
		items[resource_type] = item
		$Vertical/List.add_child(item)
	pass

func update_items(cargo: Dictionary):
	for resource_type in Constants.ResourceType.values():
		items[resource_type].set_count(cargo.get(resource_type, 0))

func toggle():
	if visible:
		visible = false
	else:
		popup_centered_minsize()
