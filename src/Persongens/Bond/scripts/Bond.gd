extends CharacterBody2D
class_name Bond

var _is_detected: bool = false
var _state_machine
var rotation_direction = 0
var hability = false
var num_victories = 0

signal player_origin(origin)

@export_category("Variables")
@export var _move_speed: float = 70.0  #4 celulas por segundo --> velocidade de movimento
# -- restrições de movimento (aceleração e fricção): argumentos de 0.0 (min) até 1.0 (máx) -- 
@export var _acceleration: float = 0.5
@export var _friction: float = 0.3
@export var rotation_speed = 1.0

@export_category("Objects")
@export var _animation_tree: AnimationTree = null

func _ready() -> void:
	''' primeira função a ser executada no objeto '''
	_animation_tree.active = true  #sempre que executar a animação, ativa-se o active animation
	_state_machine = _animation_tree["parameters/playback"]
	player_origin.emit([position, _acceleration])


func _physics_process(_delta: float) -> void:
	
	if _is_detected:
		return
		
	_move()
	_animate()
	move_and_slide()

func _move() -> void:
	var _direction: Vector2 = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)
	
	if _direction != Vector2.ZERO:  #se for diferente de um vetor nulo (aplica-se aceleração)
		
		_animation_tree["parameters/idle/blend_position"] = _direction
		_animation_tree["parameters/moviment/blend_position"] = _direction
		
		velocity.x = lerp(velocity.x, _direction.normalized().x * _move_speed, _acceleration)  
		velocity.y = lerp(velocity.y, _direction.normalized().y * _move_speed, _acceleration)
		return
	
	velocity.x = lerp(velocity.x, _direction.normalized().x * _move_speed, _friction)  # lerp() interpolação linear
	velocity.y = lerp(velocity.y, _direction.normalized().y * _move_speed, _friction)
	
	velocity = _direction.normalized() * _move_speed
	
	


		
func _animate() -> void:

	if velocity.length() > 5:
		_state_machine.travel("moviment")
		look_at(get_global_mouse_position())
		set_rotation_degrees(max(min(90, get_rotation_degrees()), -90))
		return 

	_state_machine.travel("idle")
	
