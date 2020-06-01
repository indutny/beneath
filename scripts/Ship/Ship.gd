extends RigidBody

class_name SpatialShip

signal start_docking(ship)
signal end_docking(ship)
signal start_touching_down(ship)
signal end_touching_down(ship)
signal docked(ship)
signal take_off(ship)
signal docking_position_updated(ship, position, orientation, angle)
signal entered_hyperspace(ship)
signal leaving_hyperspace(ship)
signal left_hyperspace(ship)

# Current thrust values in local comoving frame
var lateral_thrust = Vector2()
var cw_thrust = 0
var py_thrust = Vector2()
var target_velocity = 0

export(bool) var stabilization = true

export(float, 1, 20) var docking_max_forward_velocity = 3.0
export(float, 1, 20) var docking_max_backward_velocity = 3.0
export(float, 1, 20) var docking_max_lateral_velocity = 3.0

export(float, 0, 100) var max_forward_velocity = 30
export(float, 0, 100) var max_backward_velocity = 15
export(float, 0, 100) var max_lateral_velocity = 15
export(float, 0, 100) var max_total_velocity = 45
export(float, 0, 5) var max_total_angular_velocity = 1.0
export(float, 0, 1) var max_cw_angular_velocity = 0.1
export(float, 0, 1) var max_py_angular_velocity = 0.1

export(float, 1, 10000) var hyperspace_velocity = 10000.0
export(float, 1, 10000) var hyperspace_acceleration = 1000.0
export(float, 1, 10000) var hyperspace_braking = 2200.0
export(float, 1, 10000) var hyperspace_leave_velocity = 1.0
export(float, 0, 1) var hyperspace_max_py_angular_velocity = 0.025

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
var station: SpatialStation = null
var docking_state = DockingState.NOT_DOCKING

enum HyperspaceState {
	NOT_IN_HYPERSPACE,
	IN_HYPERSPACE,
	LEAVING_HYPERSPACE
}
var hyperspace_state = HyperspaceState.NOT_IN_HYPERSPACE

# Number of areas that intersect with HyperspaceSafety at different levels
var hyperspace_unsafe = [ 0, 0, 0 ]

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
	
	process_hyperspace()
		
	var velocity_proj = transform.basis.xform_inv(state.linear_velocity)
	var delta = state.step
	
	# State-dependent parameters
	var act_mx_fwd_vel = max_forward_velocity
	var act_mx_bwd_vel = max_backward_velocity
	var act_mx_lat_vel = max_lateral_velocity
	var act_mx_fwd_acc = max_forward_acceleration
	var act_mx_bwd_acc = max_backward_acceleration
	var act_mx_lat_acc = max_lateral_acceleration
	var act_mx_py_ang_vel = max_py_angular_velocity
	var act_target_vel = target_velocity
	var act_stabilization = stabilization
	
	if hyperspace_state != HyperspaceState.NOT_IN_HYPERSPACE:
		act_mx_fwd_acc = hyperspace_acceleration
		act_mx_bwd_acc = hyperspace_braking
		
		act_mx_lat_acc = hyperspace_acceleration
		
		act_mx_fwd_vel = hyperspace_velocity
		act_mx_bwd_vel = hyperspace_velocity
		act_mx_lat_vel = 0.0
		
		act_mx_py_ang_vel = hyperspace_max_py_angular_velocity
		
		act_stabilization = true
		
		# Override target velocity
		act_target_vel = hyperspace_velocity
		
		if hyperspace_state == HyperspaceState.LEAVING_HYPERSPACE:
			act_target_vel = hyperspace_leave_velocity
		else:
			act_target_vel = compute_safe_hyperspace_velocity()
	elif docking_state == DockingState.DOCKING:
		act_mx_fwd_vel = docking_max_forward_velocity
		act_mx_bwd_vel = docking_max_backward_velocity
		act_mx_lat_vel = docking_max_lateral_velocity
	
	# Apply stabilization to lateral/longtidual
	var acc = Vector3(
		lateral_thrust.x * act_mx_lat_acc,
		lateral_thrust.y * act_mx_lat_acc,
		clamp(-(act_target_vel + velocity_proj.z) / delta,
			-act_mx_fwd_acc,
			act_mx_bwd_acc))
	
	if act_stabilization:
		acc.x = apply_stabilizing_braking(
			acc.x,
			velocity_proj.x,
			act_mx_lat_vel if acc.x != 0 else 0,
			delta,
			act_mx_lat_acc)
		acc.y = apply_stabilizing_braking(
			acc.y,
			velocity_proj.y,
			act_mx_lat_vel if acc.y != 0 else 0,
			delta,
			act_mx_lat_acc)
		acc.z = apply_stabilizing_braking(
			acc.z,
			velocity_proj.z,
			act_mx_bwd_vel
				if velocity_proj.z > 0 else
				act_mx_fwd_vel,
			delta,
			act_mx_bwd_acc
				if velocity_proj.z > 0 else
				act_mx_fwd_acc)
	
	# Rotational stabilization
	var torque = Vector3(
		py_thrust.x * max_py_torque,
		py_thrust.y * max_py_torque,
		-cw_thrust * max_cw_torque)
	if act_stabilization:
		var angular_proj = transform.basis.xform_inv(state.angular_velocity)
		angular_proj /= 2 * PI
		
		# Turning must be harder at high speeds because of the speed limit
		var py_limit = min(
			act_mx_py_ang_vel,
			act_mx_lat_acc / (abs(velocity_proj.z) + epsilon))
			
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
	
	# Disable speed drag in hyperspace
	if hyperspace_state != HyperspaceState.NOT_IN_HYPERSPACE:
		space_drag *= 0.0
	
	var angular_space_drag = -angular_velocity.normalized()
	angular_space_drag *= pow(max(
		0, angular_velocity.length() - max_total_angular_velocity * 2 * PI), 2)
	
	# Apply acceleration and speed limts
	acc += space_drag
	torque += angular_space_drag
	state.add_central_force(acc)
	state.add_torque(torque)
	
func _process(delta):
	process_docking(delta)

func process_hyperspace():
	if hyperspace_state != HyperspaceState.LEAVING_HYPERSPACE:
		return
	if linear_velocity.length() <= hyperspace_leave_velocity:
		hyperspace_state = HyperspaceState.NOT_IN_HYPERSPACE
		emit_signal("left_hyperspace", self)

func process_docking(_delta):
	if docking_state != DockingState.DOCKING and \
		docking_state != DockingState.TOUCHING_DOWN:
		return
	
	var anchor = station.dock.get_touchdown_position()
	var diff = anchor.to_global(Vector3()) - \
		$Docking/Bottom.to_global(Vector3())
	
	var anchor_basis = anchor.global_transform.basis
	var anchor_normal = anchor_basis.y
	
	diff = anchor_basis.xform_inv(diff)
	diff /= station.platform_width
	
	var projected_z = transform.basis.z
	projected_z -= projected_z.dot(anchor_normal) * anchor_normal
	projected_z = projected_z.normalized()
	projected_z = anchor_basis.xform_inv(projected_z)
	
	var orientation = atan2(projected_z.x, projected_z.z)
	var angle = acos(transform.basis.y.dot(anchor_normal))
	emit_signal("docking_position_updated", self, diff, orientation, angle)
	
	if docking_state != DockingState.TOUCHING_DOWN:
		return
	
	if orientation > station.orientation_tolerance:
		return
	if angle > station.angle_tolerance:
		return

	if linear_velocity.length() > station.max_docking_velocity:
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

func take_off():
	if docking_state != DockingState.DOCKED:
		return
	
	axis_lock_angular_x = false
	axis_lock_angular_y = false
	axis_lock_angular_z = false
	axis_lock_linear_x = false
	axis_lock_linear_y = false
	axis_lock_linear_z = false
	
	sleeping = false
	
	set_station(null)
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

func enter_docking_area(station_):
	if docking_state != DockingState.NOT_DOCKING or station != null:
		return
	
	set_station(station_)
	set_docking_state(DockingState.DOCKING)
	pass

func exit_docking_area(station_):
	if docking_state != DockingState.DOCKING or station != station_:
		return
	
	set_station(null)
	set_docking_state(DockingState.NOT_DOCKING)
	pass

func enter_touchdown_area(station_):
	if docking_state != DockingState.DOCKING or station != station_:
		return
	set_docking_state(DockingState.TOUCHING_DOWN)
	pass

func exit_touchdown_area(station_):
	if docking_state != DockingState.TOUCHING_DOWN or station != station_:
		return
	set_docking_state(DockingState.DOCKING)
	pass
	
func set_station(station_: SpatialStation):
	station = station_

func toggle_hyperspace():
	match hyperspace_state:
		HyperspaceState.NOT_IN_HYPERSPACE:
			if hyperspace_unsafe[0] <= 0:
				hyperspace_state = HyperspaceState.IN_HYPERSPACE
				emit_signal("entered_hyperspace", self)
				return true
		HyperspaceState.IN_HYPERSPACE:
			hyperspace_state = HyperspaceState.LEAVING_HYPERSPACE
			emit_signal("leaving_hyperspace", self)
			return true
	return false

func on_enter_hyperspace_unsafe_level(_area, level: int):
	hyperspace_unsafe[level] += 1
	if level == 0 and hyperspace_state == HyperspaceState.IN_HYPERSPACE:
		toggle_hyperspace()

func on_exit_hyperspace_unsafe_level(_area, level: int):
	hyperspace_unsafe[level] -= 1
	
func compute_safe_hyperspace_velocity():
	if hyperspace_unsafe[0] > 0:
		return 0.0
	elif hyperspace_unsafe[1] > 0:
		return hyperspace_velocity / 15.0
	else:
		return hyperspace_velocity
