extends Spatial

const MapPoint = preload("res://scenes/Player/MapPoint.tscn")

var points = {}

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
		
		var pos: Vector3 = location.to_global(Vector3()) * scale
		var origin = (pos - center).normalized()
		
		point.transform = identity.looking_at(origin, up)
		point.transform.origin = origin
