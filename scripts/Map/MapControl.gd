extends Control

func set_name(name: String):
	$NameContaintainer/VBoxContainer/Name.text = name

func set_distance(distance: float):
	var truncated = round(distance * 10.0) / 10.0
	$NameContaintainer/VBoxContainer/Distance.visible = truncated != 0
	$NameContaintainer/VBoxContainer/Distance.text = str(truncated)
