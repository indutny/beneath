extends StaticBody
class_name Station

export(float, 0, 10) var max_docking_velocity = 1

func _on_OpenDock_body_entered(body):
	if body is Ship:
		body.enter_docking_area(self)

func _on_OpenDock_body_exited(body):
	if body is Ship:
		body.exit_docking_area(self)

func _on_Touchdown_body_entered(body):
	if body is Ship:
		body.enter_touchdown_area(self)

func _on_Touchdown_body_exited(body):
	if body is Ship:
		body.exit_touchdown_area(self)
