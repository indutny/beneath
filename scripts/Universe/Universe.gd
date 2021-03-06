extends Spatial
class_name Universe

signal universe_ready
signal new_surroundings(location, offset, surroundings)
signal leave_surroundings(location)
signal player_cargo_updated(player)
signal player_credits_updated(player)
signal player_moved(player, position)
signal player_map_updated(player)

export(float, 1e3, 1e6) var universe_scale = 1e3

var player: Player
var stations = []
var asteroid_fields = []

var tick: int = 0
var buffered_time: float = 0

func _process(delta):
	buffered_time += delta
	while buffered_time >= 1:
		buffered_time -= 1
		tick += 1
		
		for node in get_tree().get_nodes_in_group("Simulation"):
			node.process_tick(tick)

func start():
	player = $Player
	
	for station in $Stations.get_children():
		stations.append(station)
	for field in $AsteroidFeilds.get_children():
		asteroid_fields.append(field)
	
	emit_signal("universe_ready")

#
# Persistence
#

func serialize():
	return { "tick": tick }

func deserialize(data):
	tick = int(data["tick"])

#
# Surroundings
#

func _on_Player_area_entered(area: Area):
	var player_pos = player.to_global(Vector3())
	var offset = area.to_global(Vector3()) - player_pos
	
	var spatial: Spatial = area.load_spatial_instance()
	spatial.transform.basis = area.transform.basis
	emit_signal("new_surroundings", area, offset * universe_scale, spatial)


func _on_Player_area_exited(area):
	emit_signal("leave_surroundings", area)

func _on_Player_cargo_updated(player_):
	assert(player == player_)
	emit_signal("player_cargo_updated", player)


func _on_Player_credits_updated(player_):
	assert(player == player_)
	emit_signal("player_credits_updated", player)

func translate_player(shift: Vector3):
	player.global_translate(shift / universe_scale)
	emit_signal("player_moved", player, player.to_global(Vector3()))


func _on_Player_map_updated(player_):
	assert(player == player_)
	emit_signal("player_map_updated", player)

func get_default_map_location():
	return $Stations/Dirac
