extends Spatial

var enabled = false

func set_enabled(new_value):
	enabled = new_value
	visible = new_value
	$RayCast.enabled = new_value

func _process(_delta):
	if not enabled:
		return
	
	var collider = $RayCast.get_collider()
	if not collider:
		$Ray.scale.z = $RayCast.cast_to.length()
		return
	
	var distance = to_global(Vector3()).distance_to(
		$RayCast.get_collision_point())
	$Ray.scale.z = distance
