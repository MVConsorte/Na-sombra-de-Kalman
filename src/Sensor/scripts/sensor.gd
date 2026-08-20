extends Area2D

var prev_position = null
var prev_acceleration = null
var sensor_reading = null
var delta_t = 0.0
signal sensor_data(_mi, acceleration, delta_t)

func _ready():
	scale = Vector2(0, 0)
	
var factor_ruido = 0
func _on_bond_player_origin(origin):
	prev_position = origin[0] #+  origin[0]*randf_range(-1,1)*factor_ruido**(1/3)
	prev_acceleration = 0#origin[1]

func _process(delta):
	
	if $Sprite2D.texture.get_size()[0]*scale[0] >= 1500:
		scale = Vector2(0, 0)
	scale *= 2.0
	delta_t += delta

var hab_bool = true
func _on_sensor_body_entered(body):
	if hab_bool:
		if body.is_in_group("Invaders"):
			var velocity_instant = (body.position - prev_position) / delta_t
			var acceleration = prev_acceleration
			
			sensor_reading = [[body.position[0], body.position[1]], [velocity_instant[0], velocity_instant[1]]]
			
			sensor_data.emit(sensor_reading, acceleration, delta_t)
			
			prev_position = body.position
			
			delta_t = 0.0
	else:
		sensor_data.emit([[0,0],[0,0]], 0, 0.0)
