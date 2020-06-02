extends Spatial

const MapPoint = preload("res://scenes/Player/MapPoint.tscn")

var points = {}
var zero = Vector3()

func add_locations(locations: Array):
	var new_points = {}
	for x in locations:
		var point
		if points.has(x):
			point = points[x]
		else:
			point = MapPoint.instance()
		point.set_name(x.name)
		new_points[x] = point
	
	# Remove points that went away
	for key in points.keys():
		if not new_points.has(key):
			remove_child(points[key])
			points.erase(key)
	
	# Add new points
	for key in new_points.keys():
		if not points.has(key):
			var point = new_points[key]
			add_child(point)
			points[key] = point

func update(center: Vector3, scale: float, up: Vector3):
	var identity = Transform.IDENTITY
	for x in points.keys():
		var location: Spatial = x
		var point: Spatial = points[x]
		
		var pos: Vector3 = location.to_global(zero) * scale
		var offset = pos - center
		var origin = offset.normalized()
		var distance = offset.length()
		
		if is_equal_approx(abs(up.dot(origin)), 1.0):
			point.visible = false
			continue
		if origin.is_equal_approx(zero):
			point.visible = false
			continue
		
		point.visible = true
		point.transform = identity.looking_at(origin, up)
		point.transform.origin = origin
		
		point.set_distance(distance / scale)
