extends RigidBody

# Current thrust values in local comoving frame
export var lateral_thrust = Vector2()
export var thrust = 0
export var cw_thrust = 0
export var py_thrust = Vector2()

export var max_forward_velocity = 55
export var max_backward_velocity = 10
export var max_lateral_velocity = 10
export var max_total_velocity = 65
export var max_cw_angular_velocity = 0.3
export var max_py_angular_velocity = 0.3

export var max_forward_acceleration = 15
export var max_backward_acceleration = 10
export var max_lateral_acceleration = 10
export var max_cw_torque = 0.2
export var max_py_torque = 0.2

export var stabilization = true

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

func _physics_process(delta):
	var velocity_proj = transform.basis.xform_inv(linear_velocity)
	
	# Apply stabilization to lateral/longtidual
	var acc = Vector3(
		lateral_thrust.x * max_lateral_acceleration,
		lateral_thrust.y * max_lateral_acceleration,
		-thrust * (
			max_backward_acceleration
			if thrust < 0 else
			max_forward_acceleration))
	
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
			max_forward_acceleration)
	
	# Rotational stabilization
	var torque = Vector3(
		-py_thrust.x * max_py_torque,
		py_thrust.y * max_py_torque,
		-cw_thrust * max_cw_torque)
	if stabilization:
		var angular_proj = transform.basis.xform_inv(angular_velocity)
		
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
	linear_velocity += acc * delta
	angular_velocity += torque * delta
	
	linear_velocity = min(linear_velocity.length(), max_total_velocity) * \
		linear_velocity.normalized()
