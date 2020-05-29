extends Spatial

# TODO(indutny): persist this
var tick: int = 0

var buffered_time: float = 0

func _process(delta):
	buffered_time += delta
	while buffered_time >= 1:
		buffered_time -= 1
		tick += 1
		for station in $Universe/Stations.get_children():
			station.process_tick(tick)

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		$HUD.show_main_menu()

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		Persistence.save_game()

func _ready():
	Persistence.load_game()

func serialize():
	return { "tick": tick }

func deserialize(data):
	tick = int(data["tick"])
