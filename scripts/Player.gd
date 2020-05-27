extends "res://scripts/Ship.gd"
class_name Player

signal target_velocity_changed(player, new_value)
signal velocity_changed(player, new_value)
signal cargo_updated(player, total_cargo_weight, cargo)
signal credits_updated(player, credits)

export(float, 1, 10) var target_velocity_step = 5.0
export(float, 0, 1000) var max_total_cargo_weight = 100

var cargo = {}
var total_cargo_weight = 0

var credits = 0

var is_mining = false

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

func _process(_delta):
	emit_signal("velocity_changed", self, linear_velocity.length())

func _on_Player_docked(_ship):
	set_is_mining(false)

func set_is_mining(new_value):
	is_mining = new_value
	$LeftLaser.set_enabled(new_value)
	$RightLaser.set_enabled(new_value)

func _on_Laser_released_mined_resources(type, count):
	var weight = Constants.RESOURCE_WEIGHT[type] * count
	if weight + total_cargo_weight > max_total_cargo_weight:
		# TODO(indutny): display a notification or something
		return
	
	total_cargo_weight += weight
	if cargo.has(type):
		cargo[type] += count
	else:
		cargo[type] = count
	emit_signal("cargo_updated", self, total_cargo_weight, cargo)

func remove_cargo(resource_type: int, quantity: int):
	if not cargo.has(resource_type):
		return 0
	
	var max_quantity = cargo[resource_type]
	var change = clamp(quantity, 0, max_quantity)
	
	cargo[resource_type] -= change
	if cargo[resource_type] == 0:
		cargo.erase(resource_type)
		
	total_cargo_weight -= Constants.RESOURCE_WEIGHT[resource_type] * change
	emit_signal("cargo_updated", self, total_cargo_weight, cargo)
	return change

func add_credits(delta: int):
	credits += delta
	emit_signal("credits_updated", self, credits)
