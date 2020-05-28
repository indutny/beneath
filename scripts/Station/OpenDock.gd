extends Area

func get_touchdown_position():
	return $Center

func _on_Touchdown_area_entered(area):
	var body = area.owner
	if body is Ship:
		body.enter_touchdown_area($"../")

func _on_Touchdown_area_exited(area):
	var body = area.owner
	if body is Ship:
		body.exit_touchdown_area($"../")


func _on_OpenDock_area_entered(area):
	var body = area.owner
	if body is Ship:
		body.enter_docking_area($"../")

func _on_OpenDock_area_exited(area):
	var body = area.owner
	if body is Ship:
		body.exit_docking_area($"../")
