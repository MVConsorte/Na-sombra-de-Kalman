extends Label

func _ready():
	var sw_result = await SilentWolf.Scores.get_scores(0, "current_score").sw_get_scores_complete
	show()
	print("scores")
	print(sw_result.scores)
	#text = "Score: "+str(sw_result.scores[0].score)
