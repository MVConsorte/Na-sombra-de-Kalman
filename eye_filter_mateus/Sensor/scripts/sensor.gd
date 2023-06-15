extends Area2D

func _ready():
	scale = Vector2(0, 0)

func _process(delta):
	if $Sprite2D.texture.get_size()[0]*scale[0] >= 700:
		scale = Vector2(0, 0)
	scale *= 1.1

func _on_area_entered(area):
	print("!!!!!!")
