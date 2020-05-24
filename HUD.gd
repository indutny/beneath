extends HBoxContainer

func set_acceleration(value):
	$Acceleration.text = str(value)

func set_speed(value):
	$Speed.text = str(value)


func _on_Player_target_velocity_changed(new_value):
	$Acceleration.text = str(new_value)
