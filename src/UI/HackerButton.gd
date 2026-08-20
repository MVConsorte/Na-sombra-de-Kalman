extends TextureButton

func _on_button_up():
	get_tree().change_scene_to_file("res://Screens/hacker_screen.tscn")
