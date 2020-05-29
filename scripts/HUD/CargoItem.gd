extends PanelContainer

var weight = 0

func set_resource_type(resource_type):
	$MarginContainer/Horizontal/Type.text = \
		Constants.RESOURCE_NAME[resource_type]
	weight = Constants.RESOURCE_WEIGHT[resource_type]
	visible = false

func set_count(count: int):
	$MarginContainer/Horizontal/Count.text = str(count)
	$MarginContainer/Horizontal/Weight.text = str(weight * count)
	visible = count != 0
