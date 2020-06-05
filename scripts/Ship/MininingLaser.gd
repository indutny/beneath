extends Spatial

signal released_mined_resources(resource_type, count)

export(float, 0.0, 1.0) var phase_offset = 0.0

var enabled = false
var buffer = Dictionary()

var last_shader_active = null

func _ready():
	_get_shader().set_shader_param("phase_offset", phase_offset)

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
		set_shader_active(false)
		$Ray.scale.z = $RayCast.cast_to.length()
		return
	
	var is_active = false
	var distance = to_global(Vector3()).distance_to(
		$RayCast.get_collision_point())
	$Ray.scale.z = distance
	
	if collider is SpatialAsteroid:
		var asteroid: SpatialAsteroid = collider as SpatialAsteroid
		
		# Two lasers in standard equipment
		var interval = Constants.MINING_INTERVAL[asteroid.resource_type] * 2.0
		var mined = min(asteroid.resources, delta / interval)
		
		var buffer_value = buffer.get(asteroid.resource_type, 0)
		buffer_value += mined
		
		if mined > 0:
			is_active = true
		
		if buffer_value >= 1:
			var released: int =  asteroid.take_resources(int(floor(buffer_value)))
			
			buffer_value -= float(released)
			emit_signal("released_mined_resources",
				collider.resource_type, released)
		
		buffer[collider.resource_type] = buffer_value
	
	set_shader_active(is_active)

func set_shader_active(new_value: bool):
	if last_shader_active == new_value:
		return
	last_shader_active = new_value
	
	_get_shader().set_shader_param("active", 1.0 if new_value else 0.0)

func _get_shader():
	var material: ShaderMaterial = $Ray/Mesh["material/0"]
	return material
	
