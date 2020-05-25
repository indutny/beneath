extends "res://scripts/Ship.gd"

signal target_velocity_changed(player, new_value)
signal velocity_changed(player, new_value)

export(float, 1, 10) var target_velocity_step = 5.0

var max_forward_velocity_steps = \
	round(max_forward_velocity / target_velocity_step)
var max_backward_velocity_steps = \
	round(-max_backward_velocity / target_velocity_step)
const velocity_changed_step: float = 1.0


onready var last_velocity: float = round(
	linear_velocity.length() / velocity_changed_step)

func _unhandled_input(event):
	if docking_state == DockingState.DOCKED:
		return
		
	if event.is_action_pressed("ship_accelerate"):
		target_velocity = min(
			target_velocity + target_velocity_step,
			max_forward_velocity)
		emit_signal("target_velocity_changed", self, target_velocity)
	if event.is_action_pressed("ship_break"):
		target_velocity = max(
			target_velocity - target_velocity_step,
			-max_backward_velocity)
		emit_signal("target_velocity_changed", self, target_velocity)
	
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

func _process(delta):
	var current_velocity = round(
		linear_velocity.length() / velocity_changed_step)
	if abs(current_velocity- last_velocity) >= 1:
		last_velocity = current_velocity
		emit_signal(
			"velocity_changed", self, last_velocity * velocity_changed_step)
