extends Area2D

var prev_position = null
var sensor_reading = null
var delta_t = 0.0
signal sensor_data(mi, acceleration, delta_t)

func _ready():
	scale = Vector2(0, 0)

func _on_bond_player_origin(origin):
	prev_position = origin

func _process(delta):
	if $Sprite2D.texture.get_size()[0]*scale[0] >= 700:
		scale = Vector2(0, 0)
	scale *= 1.1
	delta_t += delta

func _on_sensor_body_entered(body):
	if body.is_in_group("Invaders"):
		var velocity_instant = (body.position - prev_position) / delta_t
		var acceleration = velocity_instant / delta_t
		
		sensor_reading = [body.position, velocity_instant]
		
		sensor_data.emit(sensor_reading, acceleration, delta_t)
		
		prev_position = body.position
		
		delta_t = 0.0
