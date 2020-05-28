extends StaticBody
class_name Station

export(float, 0, 10) var max_docking_velocity = 0.2
export(float, 0, 20) var platform_width = 10.0
export(float, 0, 3) var orientation_tolerance = PI / 8.0
export(float, 0, 3) var angle_tolerance = PI / 12.0
export var station_name = "Station Name"
export(int) var station_id = 0

func get_touchdown_position() -> Node:
	return $OpenDock/Center


func _on_Touchdown_area_entered(area):
	var body = area.owner
	if body is Ship:
		body.enter_touchdown_area(self)

func _on_Touchdown_area_exited(area):
	var body = area.owner
	if body is Ship:
		body.exit_touchdown_area(self)


func _on_OpenDock_area_entered(area):
	var body = area.owner
	if body is Ship:
		body.enter_docking_area(self)

func _on_OpenDock_area_exited(area):
	var body = area.owner
	if body is Ship:
		body.exit_docking_area(self)
