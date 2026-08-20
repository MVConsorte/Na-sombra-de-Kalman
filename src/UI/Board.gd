extends VBoxContainer

var player_name = ""
var pts = 0

func _ready():
	$InputNameContainer/InputName.grab_focus()
	$ConfirmButtonContainer/ConfirmButton.disabled = true
	var sw_result = await SilentWolf.Scores.get_scores(0, "current_score").sw_get_scores_complete
	
	if sw_result.scores.size() != 0:
		pts = sw_result.scores[0].score
	
func _on_input_name_text_changed(new_text):
	player_name = new_text
	if player_name.length() > 0:
		$ConfirmButtonContainer/ConfirmButton.disabled = false
	else:
		$ConfirmButtonContainer/ConfirmButton.disabled = true

func _on_confirm_button_button_up():
	save_score()

func _on_input_name_text_submitted(new_text):
	if player_name.length() > 0:
		save_score()

func save_score():
	hide()
	get_parent().get_child(5).show()
	SilentWolf.Scores.save_score(player_name, pts, "main")
	var sw_result = await SilentWolf.Scores.get_scores(10, "main").sw_get_scores_complete
	get_parent().get_child(5).hide()
	
	
	var panel = get_parent()
	
	panel.get_child(1).show()
	panel.get_child(2).show()
	panel.get_child(3).show()
