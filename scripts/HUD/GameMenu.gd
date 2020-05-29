extends PopupDialog

func _on_Save_pressed():
	Persistence.save_game()
	$Vertical/Save.disabled = true

func _on_Exit_pressed():
	Persistence.save_game()
	get_tree().quit()

func _on_Return_pressed():
	visible = false


func _on_GameMenu_about_to_show():
	$Vertical/Save.disabled = false
