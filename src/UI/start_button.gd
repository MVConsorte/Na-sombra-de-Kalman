extends Button


func _on_button_up():
	SilentWolf.Scores.wipe_leaderboard("current_score") # Apaga a tabela
	SilentWolf.Scores.save_score("Pontuação atual", 0, "current_score") # Inicializa com o valor 0
	
	get_tree().change_scene_to_file("res://Map/Tile_procedural/scenes/tile_map.tscn")
