extends "res://Ship.gd"

func _unhandled_input(event):
	if event.is_action_pressed("ship_accelerate"):
		target_velocity = min(
			target_velocity + velocity_step,
			max_forward_velocity)
		emit_signal("target_velocity_changed", target_velocity)
	if event.is_action_pressed("ship_break"):
		target_velocity = max(
			target_velocity - velocity_step,
			-max_backward_velocity)
		emit_signal("target_velocity_changed", target_velocity)
	
	lateral_thrust = Vector2(
		Input.get_action_strength("ship_lateral_right") - \
			Input.get_action_strength("ship_lateral_left"),
		Input.get_action_strength("ship_lateral_up") - \
			Input.get_action_strength("ship_lateral_down"))
	cw_thrust = Input.get_action_strength("ship_rotate_cw") - \
		Input.get_action_strength("ship_rotate_ccw")
	py_thrust = Vector2(
		Input.get_action_strength("ship_rotate_up") - \
			Input.get_action_strength("ship_rotate_down"),
		Input.get_action_strength("ship_rotate_left") - \
			event.get_action_strength("ship_rotate_right"))
