extends TextureButton

var hasActivated = false

func _on_pressed():
	if hasActivated == false:
		$TextureButton.action("hability")

		hasActivated = true
		disabled = true
