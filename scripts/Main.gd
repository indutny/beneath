extends Spatial

export(float,1.0,1000.0) var shift_origin_every = 500.0
export(float, 1, 1000) var safe_location_distance = 250.0

var universe: Universe
var accumulated_shift = Vector3()
var max_shift_speed = 10.0
var location_map = {}

func _ready():
	randomize()
	
	$Map.universe_scale = $UniverseViewport/Universe.universe_scale
	$UniverseViewport/Universe.start()

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		Persistence.save_game()
		ResourceQueue.stop()

func _on_Universe_universe_ready():
	universe = $UniverseViewport/Universe
	$Player.dual = universe.player
	$HUD.set_player($Player)
	
	Persistence.load_game()
	$UniverseViewport/Universe.translate_player(Vector3())

func _on_Universe_new_surroundings(location, offset, surroundings):
	if location_map.has(location):
		return
	
	var distance = offset.distance_to($Player.transform.origin)
	if distance < safe_location_distance:
		$Player.transform.origin += $Player.transform.basis.z * \
			(safe_location_distance - distance)
	
	location_map[location] = surroundings
	
	surroundings.transform.origin = offset
	
	var local_player_pos = surroundings.transform.xform_inv(
		$Player.transform.origin)
	surroundings.set_player_pos(local_player_pos)
	
	$Surroundings.add_child(surroundings)

func _on_Universe_leave_surroundings(location):
	if location_map.has(location):
		location_map[location].queue_free()
		location_map.erase(location)

func _on_Player_position_changed(_player, offset: Vector3):
	accumulated_shift += offset
	
	# XXX(indutny): this induces a FPS drop due to physics recalculation
	# TODO(indutny): find a way to do it without the drop
	if accumulated_shift.length() >= shift_origin_every:
		$Player.global_translate(-accumulated_shift)
		for s in $Surroundings.get_children():
			s.global_translate(-accumulated_shift)
		$UniverseViewport/Universe.translate_player(accumulated_shift)
		accumulated_shift = Vector3()

