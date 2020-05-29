extends HBoxContainer

func set_resource_type(resource_type: int):
	$Type.text = Constants.RESOURCE_NAME[resource_type]

func set_resource_count(count: int):
	$Count.text = str(count)
