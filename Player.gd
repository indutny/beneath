extends Spatial

export var max_speed = 1
export var max_lateral_speed = 0.5
export var max_backward_speed = 0.25
export var max_cw_rotation_speed = 0.05
export var max_udlr_rotation_speed = 0.05

export var max_lateral_acceleration = 0.1
export var max_forward_acceleration = 0.4
export var max_backward_acceleration = 0.3
export var max_cw_rotation_acceleration = 0.04
export var max_udlr_rotation_acceleration = 0.04

export var stabilization = true

const epsilon = 1e-23
var speed = Vector3()
var rotation_speed = Vector3()

func _ready():
	pass

func compute_stabilizing_acc(speed, delta, max_acc):
	return -sign(speed) * clamp(abs(speed) / delta, -max_acc, max_acc)

func compute_stabilizing_breaking(speed, max_speed, delta, max_acc):
	if speed > max_speed:
		return compute_stabilizing_acc(speed - max_speed, delta, max_acc)
	elif speed < -max_speed:
		return compute_stabilizing_acc(speed + max_speed, delta, max_acc)
	else:
		return 0

func _physics_process(delta):
	# Compute full acceleration
	var acc = Vector3()
	
	# Lateral
	
	var lateral_acc = Vector3()
	
	# Apply breaking
	if stabilization:
		if abs(speed.x) > max_lateral_speed:
			acc.x = compute_stabilizing_breaking(
				speed.x,
				max_lateral_speed,
				delta,
				max_lateral_acceleration)
		if abs(speed.y) > max_lateral_speed:
			acc.y = compute_stabilizing_breaking(
				speed.y,
				max_lateral_speed,
				delta,
				max_lateral_acceleration)
		if speed.z > max_backward_speed:
			acc.z = compute_stabilizing_breaking(
				speed.z,
				max_backward_speed,
				delta,
				max_forward_acceleration)
	
	if lateral_acc.y == 0:
		if Input.is_action_pressed("ship_lateral_up"):
			lateral_acc.y = 1
		elif Input.is_action_pressed("ship_lateral_down"):
			lateral_acc.y = -1
	if lateral_acc.x == 0:
		if Input.is_action_pressed("ship_lateral_left"):
			lateral_acc.x = -1
		elif Input.is_action_pressed("ship_lateral_right"):
			lateral_acc.x = 1
	
	if lateral_acc.length() != 0:
		acc += lateral_acc.normalized() * max_lateral_acceleration
		
	# Forward
	
	if Input.is_action_pressed("ship_accelerate"):
		acc.z = -max_forward_acceleration
	elif acc.z == 0 and Input.is_action_pressed("ship_break"):
		acc.z = max_backward_acceleration
	
	# Lateral position stabilization and speed compensation
	if stabilization:
		if acc.x == 0:
			acc.x += compute_stabilizing_acc(
				speed.x, delta, max_lateral_acceleration)
		if acc.y == 0:
			acc.y += compute_stabilizing_acc(
				speed.y, delta, max_lateral_acceleration)
	
	# Rotation acceleration
	
	var rot_cw_acc = 0
	var rot_udlr_acc = Vector3()
	if Input.is_action_pressed("ship_rotate_cw"):
		rot_cw_acc += 1
	if Input.is_action_pressed("ship_rotate_ccw"):
		rot_cw_acc -= 1
	if Input.is_action_pressed("ship_rotate_left"):
		rot_udlr_acc.y += 1
	if Input.is_action_pressed("ship_rotate_right"):
		rot_udlr_acc.y -= 1
	if Input.is_action_pressed("ship_rotate_up"):
		rot_udlr_acc.x -= 1
	if Input.is_action_pressed("ship_rotate_down"):
		rot_udlr_acc.x += 1
	
	rot_cw_acc *= max_cw_rotation_acceleration
	rot_udlr_acc *= max_udlr_rotation_acceleration
	
	# Rotational stabilization
	if stabilization:
		if rot_cw_acc == 0:
			rot_cw_acc = compute_stabilizing_acc(
				-rotation_speed.z,
				delta,
				max_cw_rotation_acceleration)
		if rot_udlr_acc.y == 0:
			rot_udlr_acc.y = compute_stabilizing_acc(
				rotation_speed.y,
				delta,
				max_udlr_rotation_acceleration)
		if rot_udlr_acc.x == 0:
			rot_udlr_acc.x = compute_stabilizing_acc(
				rotation_speed.x,
				delta,
				max_udlr_rotation_acceleration)
	
	# Apply acceleration and speed limts
	
	if acc.length() != 0:
		speed += acc * delta
		speed = speed.normalized() * clamp(
			speed.length(),
			-max_speed,
			max_speed)
	
	if rot_cw_acc != 0:
		rotation_speed.z -= rot_cw_acc * delta
		rotation_speed.z = clamp(
			rotation_speed.z,
			-max_cw_rotation_speed,
			max_cw_rotation_speed)
	
	if rot_udlr_acc.length() != 0:
		rotation_speed += rot_udlr_acc * delta
		var max_udlr_speed = \
			max_lateral_acceleration / (abs(speed.z) + epsilon)
		rotation_speed = rotation_speed.normalized() * min(
			rotation_speed.length(), max_udlr_speed)
	
	# Apply position change
	transform.origin += transform.basis.xform(speed * delta)
	if rotation_speed.length() != 0:
		var axis = transform.basis.xform(rotation_speed.normalized())
		var angle = rotation_speed.length() * delta * 2 * PI
		
		transform.basis = transform.basis.rotated(axis, angle)
		speed = Basis(axis, angle).xform_inv(speed)
