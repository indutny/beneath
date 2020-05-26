extends MarginContainer

export(float, 0, 5) var fade_in_duration = 0.7
export(float, 0, 5) var fade_out_duration = 3.0
export(float, -80.0, 0.0) var thrust_volume = -6.0

func _ready():
	$Column/Bottom.set_player($"../Player")

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
	$Column/Bottom.set_target_velocity(new_value)

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
	
	$Column/Bottom.set_velocity(new_value)

func _on_Player_is_docking_changed(_ship, is_docking):
	$Column/Bottom.set_is_docking(is_docking)

func _on_Player_docking_position_updated(_ship, position, orientation, angle):
	$Column/Bottom.update_docking_position(position, orientation, angle)

func _on_Player_body_entered(body):
	# TODO(indutny): play collision sound
	pass # Replace with function body.

func _on_Player_docked(ship):
	$Column/Middle/DockingSucceeded.visible = true


func _on_Undock_pressed():
	$"../Player".undock()
	$Column/Middle/DockingSucceeded.visible = false
