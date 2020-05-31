extends Spatial

var universe: Universe

func _ready():
	randomize()
	
	$UniverseViewport/Universe.start()

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		$HUD.show_main_menu()


func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		Persistence.save_game()

func _on_Universe_universe_ready():
	universe = $UniverseViewport/Universe
	$Player.dual = universe.player
	$HUD.set_player($Player)
		
	Persistence.load_game()

func _on_Universe_new_surroundings(surroundings):
	# TODO(indutny): graceful fadeout by moving Surroundings
	for child in $Surroundings.get_children():
		$Surroundings.remove_child(child)
	
	$Surroundings.add_child(surroundings)
