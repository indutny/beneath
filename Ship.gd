extends RigidBody

signal target_velocity_changed

# Current thrust values in local comoving frame
var lateral_thrust = Vector2()
var cw_thrust = 0
var py_thrust = Vector2()
var target_velocity = 0

export(bool) var manned = false

export(float) var velocity_step = 5
export(float) var max_forward_velocity_steps = 10
export(float) var max_backward_velocity_steps = 4

export(float) var max_lateral_velocity = 10
export(float) var max_total_velocity = 65
export(float) var max_cw_angular_velocity = 0.6
export(float) var max_py_angular_velocity = 0.6

export(float) var max_forward_acceleration = 15
export(float) var max_backward_acceleration = 10
export(float) var max_lateral_acceleration = 10
export(float) var max_cw_torque = 0.2
export(float) var max_py_torque = 0.2

export(bool) var stabilization = true

var max_forward_velocity = max_forward_velocity_steps * velocity_step
var max_backward_velocity = max_backward_velocity_steps * velocity_step
const epsilon = 1e-23

func apply_stabilizing_braking(
	acceleration: float,
	velocity: float,
	max_velocity: float,
	delta: float,
	max_acceleration: float):
	if velocity > max_velocity:
		return min(
			acceleration,
			clamp((max_velocity - velocity) / delta, -max_acceleration, 0))
	elif velocity < -max_velocity:
		return max(
			acceleration,
			clamp((-max_velocity - velocity) / delta, 0, max_acceleration))
	else:
		return acceleration
	
func _integrate_forces(state):
	var velocity_proj = transform.basis.xform_inv(state.linear_velocity)
	var delta = state.step
	
	# Apply stabilization to lateral/longtidual
	var acc = Vector3(
		lateral_thrust.x * max_lateral_acceleration,
		lateral_thrust.y * max_lateral_acceleration,
		clamp((target_velocity + velocity_proj.z) / delta,
			max_backward_acceleration,
			-max_forward_acceleration))
	
	if stabilization:
		acc.x = apply_stabilizing_braking(
			acc.x,
			velocity_proj.x,
			max_lateral_velocity if acc.x != 0 else 0,
			delta,
			max_lateral_acceleration)
		acc.y = apply_stabilizing_braking(
			acc.y,
			velocity_proj.y,
			max_lateral_velocity if acc.y != 0 else 0,
			delta,
			max_lateral_acceleration)
		acc.z = apply_stabilizing_braking(
			acc.z,
			velocity_proj.z,
			max_backward_velocity
				if velocity_proj.z > 0 else max_forward_velocity,
			delta,
			max_backward_acceleration
				if velocity_proj.z > 0 else max_forward_acceleration)
	
	# Rotational stabilization
	var torque = Vector3(
		-py_thrust.x * max_py_torque,
		py_thrust.y * max_py_torque,
		-cw_thrust * max_cw_torque)
	if stabilization:
		var angular_proj = transform.basis.xform_inv(state.angular_velocity)
		
		# Turning must be harder at high speeds because of the speed limit
		var py_limit = min(
			max_py_angular_velocity,
			max_lateral_acceleration / (abs(velocity_proj.z) + epsilon))
		
		torque.x = apply_stabilizing_braking(
			torque.x,
			angular_proj.x,
			py_limit if py_thrust.x != 0 else 0,
			delta,
			max_py_torque)
		torque.y = apply_stabilizing_braking(
			torque.y,
			angular_proj.y,
			py_limit if py_thrust.y != 0 else 0,
			delta,
			max_py_torque)
		torque.z = apply_stabilizing_braking(
			torque.z,
			angular_proj.z,
			max_cw_angular_velocity if cw_thrust != 0 else 0,
			delta,
			max_cw_torque)
	
	
	# Apply acceleration and speed limts
	acc = transform.basis.xform(acc)
	torque = transform.basis.xform(torque) * 2 * PI
	state.add_central_force(acc)
	state.add_torque(torque)

func _unhandled_input(event):
	if not manned:
		return
	
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
