extends VBoxContainer

signal update_building(building)

const ProductionItem = preload("res://scenes/HUD/StationProductionItem.tscn")

var player: Player
var building: StationBuilding

func init(player_: Player, building_: StationBuilding):
	player = player_
	building = building_
	update()

func update():
	var selected = $Top/Type.selected
	if selected != -1:
		selected = $Top/Type.get_item_id(selected)
	
	$Top/Type.clear()
	for building_type in Constants.BuildingType.values():
		if building.building_type != Constants.BuildingType.Vacant and \
			building_type == Constants.BuildingType.Vacant:
			continue
		$Top/Type.add_item(Constants.BUILDING_NAME[building_type], \
			building_type)
		if building_type == Constants.BuildingType.Vacant:
			$Top/Type.add_separator()
	
	if selected != -1:
		$Top/Type.select($Top/Type.get_item_index(selected))
	else:
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
	
	var requirements = Constants.BUILDING_COST[id]
	var cost = requirements[0]
	var required_resources = requirements[1]
	$Top/CostBox/Cost.text = str(cost)
	
	$Top/Action.disabled = not player.has_credits(cost) or \
		not player.station.has_resources(required_resources)
	
	# Clear resources/consumption/production
	for child in $Top/CostBox/Resources.get_children():
		$Top/CostBox/Resources.remove_child(child)
	for child in $Middle/Consumes.get_children():
		$Middle/Consumes.remove_child(child)
	for child in $Bottom/Produces.get_children():
		$Bottom/Produces.remove_child(child)
	
	# Re-add resources/consumption/production
	for child in to_production_nodes(required_resources):
		$Top/CostBox/Resources.add_child(child)

	var consumes = Constants.BUILDING_CONSUMES[id]
	for child in to_production_nodes(consumes):
		$Middle/Consumes.add_child(child)
	
	var produces = Constants.BUILDING_PRODUCES[id]
	for child in to_production_nodes(produces):
		$Bottom/Produces.add_child(child)

func to_production_nodes(map):
	var out = []
	for resource_type in map.keys():
		var item = ProductionItem.instance()
		item.set_resource_type(resource_type)
		item.set_resource_count(map[resource_type])
		out.append(item)
	return out

func _on_Action_pressed():
	var type = $Top/Type.get_item_id($Top/Type.selected)
	var requirements = Constants.BUILDING_COST[type]
	var cost = requirements[0]
	var resources = requirements[1]
	if not player.has_credits(cost) or \
		not player.station.has_resources(resources):
		return
	
	var spent = player.spend_credits(cost)
	assert(spent)
	
	var retrieved = player.station.retrieve_resources(resources)
	for key in resources.keys():
		assert(retrieved[key] == resources[key])
	
	building.building_type = type
	emit_signal("update_building", building)
