extends "res://scripts/Ship/Ship.gd"
class_name SpatialPlayer

signal target_velocity_changed(player, new_value)
signal velocity_changed(player, new_value)

var dual: Player

export(float, 1, 10) var target_velocity_step = 5.0
export(float, 0.1, 1.0) var velocity_changed_step = 0.5

var is_mining = false
var last_reported_velocity = 0.0

var max_forward_velocity_steps = \
	round(max_forward_velocity / target_velocity_step)
var max_backward_velocity_steps = \
	round(-max_backward_velocity / target_velocity_step)

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
		
	if event.is_action_pressed("ship_toggle_spotlight"):
		$SpotLight.visible = not $SpotLight.visible
	
	if event.is_action_pressed("ship_fire"):
		set_is_mining(true)
	elif event.is_action_released("ship_fire"):
		set_is_mining(false)
	
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
			Input.get_action_strength("ship_rotate_right"))

func set_station(station_: SpatialStation):
	.set_station(station_)
	dual.station = station_.dual if station_ else null

func _process(_delta):
	if docking_state == DockingState.DOCKED:
		return
	
	var current_velocity = linear_velocity.length()
	if abs(current_velocity - last_reported_velocity) >= velocity_changed_step:
		last_reported_velocity = current_velocity
		emit_signal("velocity_changed", self, current_velocity)

func _on_Player_docked(_ship):
	set_is_mining(false)
	emit_signal("velocity_changed", self, 0)

func set_is_mining(new_value):
	is_mining = new_value
	$LeftLaser.set_enabled(new_value)
	$RightLaser.set_enabled(new_value)

func _on_Laser_released_mined_resources(type, count):
	var _stored = dual.store_cargo(type, count)

