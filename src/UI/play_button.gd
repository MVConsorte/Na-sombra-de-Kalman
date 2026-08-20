extends Button

func _ready():
	SilentWolf.Scores.save_score("Pontuação atual", 0, "current_score") # Inicializa com o valor 0

func _on_button_up():
	get_tree().change_scene_to_file("res://Screens/selection_screen.tscn")
