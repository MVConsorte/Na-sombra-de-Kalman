extends Button

func _on_button_up():
	get_tree().change_scene_to_file("res://addons/silent_wolf/Scores/Leaderboard.tscn")
