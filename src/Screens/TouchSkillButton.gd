extends TouchScreenButton

var hasActivated = false


func _on_pressed():
	
	if hasActivated == false:
		
		hasActivated = true
		set_visible(false)
