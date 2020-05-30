extends "res://scripts/Ship/Ship.gd"
class_name Player

signal target_velocity_changed(player, new_value)
signal velocity_changed(player, new_value)
signal cargo_updated(player, total_cargo_weight, cargo)
signal credits_updated(player, credits)

export(float, 1, 10) var target_velocity_step = 5.0
export(float, 0, 1000) var max_total_cargo_weight = 100
export(Vector3) var universe_pos = Vector3()

var cargo = {}

# TODO(indutny): update inertia
var total_cargo_weight: float = 0

var credits: int = 0

var is_mining = false

var max_forward_velocity_steps = \
	round(max_forward_velocity / target_velocity_step)
var max_backward_velocity_steps = \
	round(-max_backward_velocity / target_velocity_step)
	
# Persistence
func serialize():
	return {
		"cargo": cargo,
		"credits": credits
	}

func deserialize(data):
	for resource_type in data["cargo"].keys():
		cargo[int(resource_type)] = int(data["cargo"][resource_type])
	credits = int(data["credits"])
	
	# Recompute weight
	total_cargo_weight = 0
	for resource_type in cargo.keys():
		var weight = Constants.RESOURCE_WEIGHT[resource_type]
		total_cargo_weight += weight * cargo[resource_type]
	
	emit_signal("cargo_updated", self, total_cargo_weight, cargo)
	emit_signal("credits_updated", self, credits)

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
	if docking_state == DockingState.DOCKED:
		return
	emit_signal("velocity_changed", self, linear_velocity.length())

func _on_Player_docked(_ship):
	set_is_mining(false)
	emit_signal("velocity_changed", self, 0)

func set_is_mining(new_value):
	is_mining = new_value
	$LeftLaser.set_enabled(new_value)
	$RightLaser.set_enabled(new_value)

func _on_Laser_released_mined_resources(type, count):
	var _stored = store_cargo(type, count)

func retrieve_cargo(resource_type: int, quantity: int) -> int:
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

func store_cargo(resource_type: int, quantity: int) -> int:
	var capacity = max_total_cargo_weight - total_cargo_weight
	capacity /= Constants.RESOURCE_WEIGHT[resource_type]
	capacity = floor(capacity)
	
	var to_store = clamp(quantity, 0, capacity)
	if to_store == 0:
		return to_store
	
	cargo[resource_type] = cargo.get(resource_type, 0) + to_store
	total_cargo_weight += to_store * Constants.RESOURCE_WEIGHT[resource_type]
	emit_signal("cargo_updated", self, total_cargo_weight, cargo)
	return to_store
	
func add_credits(delta: int):
	credits += delta
	emit_signal("credits_updated", self, credits)

func spend_credits(delta: int) -> bool:
	if credits < delta:
		return false
	credits -= delta
	emit_signal("credits_updated", self, credits)
	return true
