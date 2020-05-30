extends Spatial
class_name Universe

signal universe_ready
signal new_surroundings(node)
signal player_cargo_updated(player)
signal player_credits_updated(player)

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
		for station in $Stations.get_children():
			station.process_tick(tick)

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		Persistence.save_game()

func _ready():
	Persistence.load_game()
	
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

func _on_Player_area_entered(area):
	var spatial: Spatial = area.load_spatial_instance()
	spatial.transform.basis = area.transform.basis
	spatial.transform.origin = \
		(area.transform.origin - player.transform.origin) * universe_scale
	emit_signal("new_surroundings", spatial)


func _on_Player_cargo_updated(player):
	emit_signal("player_cargo_updated", player)


func _on_Player_credits_updated(player):
	emit_signal("player_credits_updated", player)
