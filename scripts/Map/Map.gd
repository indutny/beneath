extends Spatial

var player: Player
var universe_scale: float = 1.0
var points = {}

const MapPoint = preload("res://scenes/Map/MapPoint.tscn")

func _unhandled_input(event):
	if not event.is_action_pressed("hud_map"):
		return
	
	visible = not visible

func update_points():
	var player_pos: Vector3 = player.to_global(Vector3())
	for x in points.keys():
		var location: Spatial = x
		var point: Spatial = points[location]
		
		var location_pos: Vector3 = location.to_global(Vector3())
		var offset = location_pos - player_pos
		
		point.transform.origin = offset * universe_scale;
		point.set_distance(offset.length())

func _on_Universe_player_map_updated(player_: Player):
	if player:
		assert(player == player_)
	player = player_
	
	var locations = player.get_map_locations()
	
	var new_points = {}
	for x in locations:
		var location: Spatial = x
		
		var point
		if points.has(location):
			point = points[location]
		else:
			point = MapPoint.instance()
		
		point.set_name(location.name)
		
		new_points[location] = point
	
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
	
	update_points()


func _on_Universe_player_moved(player_, _position):
	if player:
		assert(player == player_)
	player = player_
	update_points()
