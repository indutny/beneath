extends RigidBody

# Current thrust values in local comoving frame
var lateral_thrust = Vector2()
var cw_thrust = 0
var py_thrust = Vector2()
var target_velocity = 0

export(bool) var stabilization = true

export(float) var max_forward_velocity = 30
export(float) var max_backward_velocity = 15
export(float) var max_lateral_velocity = 15
export(float) var max_total_velocity = 45
export(float) var max_total_angular_velocity = 1.0
export(float) var max_cw_angular_velocity = 0.1
export(float) var max_py_angular_velocity = 0.1

export(float) var max_forward_acceleration = 15
export(float) var max_backward_acceleration = 5
export(float) var max_lateral_acceleration = 5
export(float) var max_cw_torque = 0.2
export(float) var max_py_torque = 0.2

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
		clamp(-(target_velocity + velocity_proj.z) / delta,
			-max_forward_acceleration,
			max_backward_acceleration))
	
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
	var torque_impulse = Vector3()
	if stabilization:
		var angular_proj = transform.basis.xform_inv(state.angular_velocity)
		angular_proj /= 2 * PI
		
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
	
	acc = transform.basis.xform(acc)
	torque = transform.basis.xform(torque) * 2 * PI

	# Totally unphysical, but makes it more playable	
	var space_drag = -linear_velocity.normalized()
	space_drag *= pow(max(0, linear_velocity.length() - max_total_velocity), 2)
	
	var angular_space_drag = -angular_velocity.normalized()
	angular_space_drag *= pow(max(
		0, angular_velocity.length() -max_total_angular_velocity * 2 * PI), 2)
	
	# Apply acceleration and speed limts
	acc += space_drag
	torque += angular_space_drag
	state.add_central_force(acc)
	state.add_torque(torque)
