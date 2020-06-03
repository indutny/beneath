extends Spatial

func set_name(name: String):
	$Viewport/Control.set_name(name)

func set_distance(distance: float):
	$Viewport/Control.set_distance(distance)
	$Viewport/Control.modulate.a = pow(0.8, distance)
	$Viewport.render_target_update_mode = Viewport.UPDATE_ONCE
