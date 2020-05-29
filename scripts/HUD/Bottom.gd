extends HBoxContainer

var player: Player

func set_player(player_: Player):
	player = player_
	$Velocity.max_value = player.max_total_velocity
	$TargetVelocity.max_value = max(
		player.max_backward_velocity,
		player.max_forward_velocity)

func set_target_velocity(new_value: float):
	$TargetVelocity.value = abs(new_value)
	$TargetVelocity.modulate = Color.red if new_value < 0 else Color.white
	
func set_velocity(new_value):
	$VelocityTween.interpolate_property(
		$Velocity,
		"value",
		$Velocity.value,
		new_value,
		0.1,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN,
		0)
	$VelocityTween.start()

func set_is_docking(is_docking):
	$DockingIndicatorTween.stop_all()
	# TODO(indutny): use texture
	var nodes = [
		$Docking/Indicator,
		$Docking/Horizontal,
		$Docking/Vertical
	]
	for ui in nodes:
		var color = ui.color
	
		$DockingIndicatorTween.interpolate_property(
			ui,
			"color",
			color,
			Color(color.r, color.g, color.b, 1.0 if is_docking else 0.0),
			0.5,
			Tween.TRANS_LINEAR,
			Tween.EASE_IN,
			0)
	$DockingIndicatorTween.start()

func update_docking_position(position, orientation, _angle):
	var indicator = $Docking/Indicator
	var center = ($Docking.rect_size - indicator.rect_size) / 2
	
	indicator.rect_position = center - \
		Vector2(position.x * center.x, position.z * center.y) / 2
	indicator.rect_scale = Vector2(1, 1) * exp(abs(position.y))
	indicator.rect_rotation = -orientation / (2 * PI) * 360
