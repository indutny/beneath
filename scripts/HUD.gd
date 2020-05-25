extends HBoxContainer

const fade_in_duration = 0.7
const fade_out_duration = 3.0

func set_acceleration(value):
	$Acceleration.text = str(value)

func set_speed(value):
	$Speed.text = str(value)

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
		0,
		fade_in_duration,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN,
		0)
	$FadeIn.start()

func _on_Player_target_velocity_changed(new_value):
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
	
	$Acceleration.text = str(new_value)

func _on_FadeOut_tween_completed(object, key):
	object.stop()
