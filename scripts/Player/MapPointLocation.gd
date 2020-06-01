extends Control

func set_name(name: String):
	$NameContaintainer/VBoxContainer/Name.text = name

func set_distance(distance: float):
	$NameContaintainer/VBoxContainer/Distance.text = str(
		round(distance * 10.0) / 10.0)
