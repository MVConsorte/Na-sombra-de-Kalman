extends Label
@onready var olho_de_kalman = get_parent().get_parent().get_child(0)


func _ready():
	var sw_result = await SilentWolf.Scores.get_scores(0, "current_score").sw_get_scores_complete
	text = "Pontuação:  "#+str(sw_result.scores[0].score)
	#olho_de_kalman.points = 0
