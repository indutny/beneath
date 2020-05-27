extends Spatial

export(float, 0, 100) var mining_speed = 0.5

signal released_mined_resources(resource_type, count)

var enabled = false
var buffer = Dictionary()

func set_enabled(new_value):
	enabled = new_value
	visible = new_value
	$RayCast.enabled = new_value
	
	if not new_value:
		buffer.clear()

func _process(delta):
	if not enabled:
		return
	
	var collider = $RayCast.get_collider()
	if not collider:
		$Ray.scale.z = $RayCast.cast_to.length()
		return
	
	var distance = to_global(Vector3()).distance_to(
		$RayCast.get_collision_point())
	$Ray.scale.z = distance
	
	if collider is Asteroid:
		var mined = min(collider.resources, mining_speed * delta)
		var buffer_value = 0
		
		if buffer.has(collider.resource_type):
			buffer_value = buffer[collider.resource_type]
		buffer_value += mined
		collider.resources -= mined
	
		if buffer_value >= 1:
			var released = floor(buffer_value)
			buffer_value -= released
			emit_signal("released_mined_resources",
				collider.resource_type, released)
		
		buffer[collider.resource_type] = buffer_value
