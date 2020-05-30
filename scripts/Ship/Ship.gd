extends RigidBody

class_name Ship

signal start_docking(ship)
signal end_docking(ship)
signal start_touching_down(ship)
signal end_touching_down(ship)
signal docked(ship)
signal take_off(ship)
signal docking_position_updated(ship, position, orientation, angle)

# Current thrust values in local comoving frame
var lateral_thrust = Vector2()
var cw_thrust = 0
var py_thrust = Vector2()
var target_velocity = 0

export(bool) var stabilization = true

export(float, 1, 20) var docking_forward_reduction = 10.0
export(float, 1, 20) var docking_backward_reduction = 2.5
export(float, 1, 20) var docking_lateral_reduction = 2.5

export(float, 0, 100) var max_forward_velocity = 30
export(float, 0, 100) var max_backward_velocity = 15
export(float, 0, 100) var max_lateral_velocity = 15
export(float, 0, 100) var max_total_velocity = 45
export(float, 0, 5) var max_total_angular_velocity = 1.0
export(float, 0, 1) var max_cw_angular_velocity = 0.1
export(float, 0, 1) var max_py_angular_velocity = 0.1

export(float, 0, 30) var max_forward_acceleration = 15
export(float, 0, 30) var max_backward_acceleration = 4
export(float, 0, 30) var max_lateral_acceleration = 4
export(float, 0, 1) var max_cw_torque = 0.5
export(float, 0, 1) var max_py_torque = 0.5

# Docking

enum DockingState {
	NOT_DOCKING,
	DOCKING,
	TOUCHING_DOWN,
	DOCKED,
}
var current_station = null
var docking_state = DockingState.NOT_DOCKING

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
	if docking_state == DockingState.DOCKED:
		return
		
	var velocity_proj = transform.basis.xform_inv(state.linear_velocity)
	var delta = state.step
	
	var forward_reduction = 1
	var backward_reduction = 1
	var lateral_reduction = 1
	if docking_state == DockingState.DOCKING:
		forward_reduction = docking_forward_reduction
		backward_reduction = docking_backward_reduction
		lateral_reduction = docking_lateral_reduction
	
	# Apply stabilization to lateral/longtidual
	var acc = Vector3(
		lateral_thrust.x * max_lateral_acceleration / lateral_reduction,
		lateral_thrust.y * max_lateral_acceleration / lateral_reduction,
		clamp(-(target_velocity + velocity_proj.z) / delta,
			-max_forward_acceleration / forward_reduction,
			max_backward_acceleration / backward_reduction))
	
	if stabilization:
		acc.x = apply_stabilizing_braking(
			acc.x,
			velocity_proj.x,
			max_lateral_velocity / lateral_reduction if acc.x != 0 else 0,
			delta,
			max_lateral_acceleration)
		acc.y = apply_stabilizing_braking(
			acc.y,
			velocity_proj.y,
			max_lateral_velocity / lateral_reduction if acc.y != 0 else 0,
			delta,
			max_lateral_acceleration)
		acc.z = apply_stabilizing_braking(
			acc.z,
			velocity_proj.z,
			max_backward_velocity / backward_reduction
				if velocity_proj.z > 0 else
				max_forward_velocity / forward_reduction,
			delta,
			max_backward_acceleration
				if velocity_proj.z > 0 else max_forward_acceleration)
	
	# Rotational stabilization
	var torque = Vector3(
		py_thrust.x * max_py_torque,
		py_thrust.y * max_py_torque,
		-cw_thrust * max_cw_torque)
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
		0, angular_velocity.length() - max_total_angular_velocity * 2 * PI), 2)
	
	# Apply acceleration and speed limts
	acc += space_drag
	torque += angular_space_drag
	state.add_central_force(acc)
	state.add_torque(torque)
	
func _process(_delta):
	if docking_state != DockingState.DOCKING and \
		docking_state != DockingState.TOUCHING_DOWN:
		return
	
	var anchor = current_station.dock.get_touchdown_position()
	var diff = anchor.to_global(Vector3()) - \
		$Docking/Bottom.to_global(Vector3())
	
	var anchor_basis = anchor.global_transform.basis
	var anchor_normal = anchor_basis.y
	
	diff = anchor_basis.xform_inv(diff)
	diff /= current_station.platform_width
	
	var projected_z = transform.basis.z
	projected_z -= projected_z.dot(anchor_normal) * anchor_normal
	projected_z = projected_z.normalized()
	projected_z = anchor_basis.xform_inv(projected_z)
	
	var orientation = atan2(projected_z.x, projected_z.z)
	var angle = acos(transform.basis.y.dot(anchor_normal))
	emit_signal("docking_position_updated", self, diff, orientation, angle)
	
	if docking_state != DockingState.TOUCHING_DOWN:
		return
	
	if orientation > current_station.orientation_tolerance:
		return
	if angle > current_station.angle_tolerance:
		return

	if linear_velocity.length() > current_station.max_docking_velocity:
		return
	
	axis_lock_angular_x = true
	axis_lock_angular_y = true
	axis_lock_angular_z = true
	axis_lock_linear_x = true
	axis_lock_linear_y = true
	axis_lock_linear_z = true
	
	sleeping = true
	
	lateral_thrust *= 0
	cw_thrust *= 0
	py_thrust *= 0
	target_velocity *= 0
	
	set_docking_state(DockingState.DOCKED)

func undock():
	if docking_state != DockingState.DOCKED:
		return
	
	axis_lock_angular_x = false
	axis_lock_angular_y = false
	axis_lock_angular_z = false
	axis_lock_linear_x = false
	axis_lock_linear_y = false
	axis_lock_linear_z = false
	
	sleeping = false
	
	current_station = null
	set_docking_state(DockingState.NOT_DOCKING)


func set_docking_state(state):
	if docking_state == state:
		return
	
	if docking_state == DockingState.DOCKING and state == DockingState.NOT_DOCKING:
		self.emit_signal("end_docking", self)
	elif docking_state == DockingState.TOUCHING_DOWN and \
		state == DockingState.DOCKING:
		self.emit_signal("end_touching_down", self)
	elif docking_state == DockingState.DOCKED and \
		state == DockingState.NOT_DOCKING:
		self.emit_signal("take_off", self)
	
	docking_state = state
	
	if docking_state == DockingState.DOCKING:
		self.emit_signal("start_docking", self)
	elif docking_state == DockingState.TOUCHING_DOWN:
		self.emit_signal("start_touching_down", self)
	elif docking_state == DockingState.DOCKED:
		self.emit_signal("docked", self)

func enter_docking_area(station):
	if docking_state != DockingState.NOT_DOCKING or current_station != null:
		return
	
	current_station = station
	set_docking_state(DockingState.DOCKING)
	pass

func exit_docking_area(station):
	if docking_state != DockingState.DOCKING or station != current_station:
		return
	
	current_station = null
	set_docking_state(DockingState.NOT_DOCKING)
	pass

func enter_touchdown_area(station):
	if docking_state != DockingState.DOCKING or station != current_station:
		return
	set_docking_state(DockingState.TOUCHING_DOWN)
	pass

func exit_touchdown_area(station):
	if docking_state != DockingState.TOUCHING_DOWN or station != current_station:
		return
	set_docking_state(DockingState.DOCKING)
	pass
