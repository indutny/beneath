extends HBoxContainer

export(float, 0, 5) var fade_in_duration = 0.7
export(float, 0, 5) var fade_out_duration = 3.0
export(float, -80.0, 0.0) var thrust_volume = -6.0

func _ready():
	$Velocity.max_value = $"../Player".max_total_velocity
	$TargetVelocity.min_value = -$"../Player".max_backward_velocity
	$TargetVelocity.max_value = $"../Player".max_forward_velocity

func fade_out(player: AudioStreamPlayer):
	$FadeIn.stop(player)
	$FadeOut.stop(player)
	$FadeOut.interpolate_property(
		player,
		"volume_db",
		player.volume_db,
		-80,
		fade_out_duration,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN,
		0)
	$FadeOut.start()

func fade_in(player: AudioStreamPlayer):
	if not player.playing:
		player.play()
	$FadeIn.stop(player)
	$FadeOut.stop(player)
	$FadeIn.interpolate_property(
		player,
		"volume_db",
		player.volume_db,
		thrust_volume,
		fade_in_duration,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN,
		0)
	$FadeIn.start()


func _on_FadeOut_tween_completed(object, _key):
	object.stop()

func _on_Player_target_velocity_changed(_player, new_value):
	$VelocityTween.interpolate_property(
		$TargetVelocity,
		"value",
		$TargetVelocity.value,
		new_value,
		0.1,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN,
		0)
	$VelocityTween.start()

func _on_Player_velocity_changed(_player, new_value):
	if new_value == 0:
		fade_out($ThrustSound)
	else:
		fade_in($ThrustSound)
	
	$Pitch.stop($ThrustSound)
	$Pitch.interpolate_property(
		$ThrustSound,
		"pitch_scale",
		$ThrustSound.pitch_scale,
		1 + abs(new_value) / 100,
		fade_in_duration,
		0)
	$Pitch.start()
	
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


func _on_Player_is_docking_changed(_ship, is_docking):
	$DockingIndicatorTween.stop_all()
	# TODO(indutny): use texture
	for ui in [ $Docking/Indicator, $Docking/Horizontal, $Docking/Vertical ]:
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


func _on_Player_docking_position_updated(_ship, position, orientation, angle):
	var indicator = $Docking/Indicator
	var center = ($Docking.rect_size - indicator.rect_size) / 2
	
	indicator.rect_position = center - \
		Vector2(position.x * center.x, position.z * center.y) / 2
	indicator.rect_scale = Vector2(1, 1) * exp(abs(position.y))
	indicator.rect_rotation = orientation / (2 * PI) * 360


func _on_Player_body_entered(body):
	# TODO(indutny): play collision sound
	pass # Replace with function body.
