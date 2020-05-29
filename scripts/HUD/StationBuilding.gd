extends VBoxContainer

const ProductionItem = preload("res://scenes/HUD/StationProductionItem.tscn")

func _ready():
	for building_type in Constants.BuildingType.values():
		$Top/Type.add_item(Constants.BUILDING_TYPE[building_type], building_type)
	_on_Type_item_selected($Top/Type.selected)


func _on_Type_item_selected(id):
	$Top/Cost.text = str(Constants.BUILDING_COST[id])
	
	var produces = Constants.BUILDING_PRODUCES[id]
	var consumes = Constants.BUILDING_CONSUMES[id]
	
	for child in $Bottom/Produces.get_children():
		$Bottom/Produces.remove_child(child)
	for child in $Bottom/Consumes.get_children():
		$Bottom/Consumes.remove_child(child)
		
	for child in to_production_nodes(produces):
		$Bottom/Produces.add_child(child)
	for child in to_production_nodes(consumes):
		$Bottom/Consumes.add_child(child)

func to_production_nodes(list):
	var out = []
	for resource_type in list:
		var item = ProductionItem.instance()
		item.set_resource_type(resource_type)
		item.set_resource_count(list[resource_type])
		out.append(item)
	return out
