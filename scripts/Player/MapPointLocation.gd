extends Control

var last_distance = null

func set_name(name: String):
	$NameContaintainer/VBoxContainer/Name.text = name

func set_distance(distance: float):
	var truncated = round(distance * 10.0) / 10.0
	if last_distance == truncated:
		return
	last_distance = truncated
	$NameContaintainer/VBoxContainer/Distance.visible = truncated != 0
	$NameContaintainer/VBoxContainer/Distance.text = str(truncated)
