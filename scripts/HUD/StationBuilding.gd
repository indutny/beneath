extends VBoxContainer

const ProductionItem = preload("res://scenes/HUD/StationProductionItem.tscn")

var building: StationBuilding

func set_building(building_: StationBuilding):
	building = building_
	
	$Top/Type.clear()
	for building_type in Constants.BuildingType.values():
		if building.building_type != Constants.BuildingType.Vacant and \
			building_type == Constants.BuildingType.Vacant:
			continue
		$Top/Type.add_item(Constants.BUILDING_TYPE[building_type], \
			building_type)
		if building_type == Constants.BuildingType.Vacant:
			$Top/Type.add_separator()
	
	$Top/Type.select($Top/Type.get_item_index(building.building_type))
	_on_Type_item_selected($Top/Type.selected)

	if building.building_type != Constants.BuildingType.Vacant:
		$Top/Action.text = str("Replace")

func _on_Type_item_selected(idx):
	var id = $Top/Type.get_item_id(idx)
	$Top/Action.visible = \
		id != building.building_type and \
		id != Constants.BuildingType.Vacant
	
	$Top/CostBox.visible = $Top/Action.visible
	
	# Clear consumption/production
	for child in $Middle/Consumes.get_children():
		$Middle/Consumes.remove_child(child)
	for child in $Bottom/Produces.get_children():
		$Bottom/Produces.remove_child(child)		
	
	$Top/CostBox/Cost.text = str(Constants.BUILDING_COST[id])
			
	var consumes = Constants.BUILDING_CONSUMES[id]
	for child in to_production_nodes(consumes):
		$Middle/Consumes.add_child(child)
	
	var produces = Constants.BUILDING_PRODUCES[id]
	for child in to_production_nodes(produces):
		$Bottom/Produces.add_child(child)

func to_production_nodes(list):
	var out = []
	for resource_type in list:
		var item = ProductionItem.instance()
		item.set_resource_type(resource_type)
		item.set_resource_count(list[resource_type])
		out.append(item)
	return out
