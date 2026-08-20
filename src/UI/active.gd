extends Label


func _on_skill_button_pressed():
	set_visible(true)


func _on_timer_timeout():
	set_visible(false)
