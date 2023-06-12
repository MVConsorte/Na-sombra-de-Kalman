extends CharacterBody2D

class_name Eye_kalman

var _Bond_ref = null
var percent = 0
var timer = Timer.new()
var in_real_colision = false

@export_category("Objects")
@export var _texture: Sprite2D = null
@export var _animation: AnimationPlayer = null



func _on_sensor_area_body_entered(_body) -> void:
	if _body.is_in_group("Invaders"):
		_Bond_ref = _body


func _on_sensor_area_body_exited(_body) -> void:
	if _body.is_in_group("Invaders"):
		_Bond_ref = null


func _on_real_view_body_entered(_body):
	if _body.is_in_group("Invaders"):
		#timer.start()
		in_real_colision = true
		print(timer.time_left)
		if timer.timeout:
			percent += 1
			print(percent)


func _on_real_view_body_exited(body):
	in_real_colision = false
	timer.stop()
		
		
func _on_timer_timeout():
	if in_real_colision:
		percent += 1
		print(percent)	
	set_physics_process(true)
	
	
func _physics_process(_delta: float) -> void:
	
	_animate()
	if _Bond_ref != null:
		var _direction: Vector2 = global_position.direction_to(_Bond_ref.global_position)
		velocity = _direction * 40
		move_and_slide()
		
func _animate() -> void:
	
	if percent < 20:
		_animation.play("0_percent_view") 
		return
	if percent < 40:
		_animation.play("20_percent_view") 
		return
	if percent < 60:
		_animation.play("40_percent_view") 
		return
	if percent < 80:
		_animation.play("60_percent_view") 
		return
	if percent < 100:
		_animation.play("80_percent_view") 
		return

	_animation.play("100_percent_view") 





# receber vetor de estado (2x2) - Linha1: posição; Linha2: velocidade
# receber entradas de controle (1x2) - aceleração de x, de y

# parâmetros constantes
var dt = 1.0 # número de atualizações por intervalo --> definido pelo sensor
#tempo de simulação: até atingir 100% de visibilidade

# processo / predição
var _A = [[1,dt],[0,1]] 
var _B = [dt**2/2, dt]

var sigma_d: float = 0.25   #desvio padrão da posição
var sigma_v: float = 0.15	#desvio padrão da velocidade
var _R = [[sigma_d**2,0],[0,sigma_v**2]]    #CovariÂncia do Processo

#Observação / Correção
var C = [1,0]   

var sigma_l: float = 0.2	#Desvio padrão de l (dist)
var Q = [sigma_l**2,0]         #Covariância da observação

## Inicialização
	# v # velocidade inicial 
	# mi # Estado: posição (x,y - do forte); velocidade (0,0) 
	# S # Covariância do estado (inicialmente - perfeita ([0,0],[0,0])

	# u # aceleração (aceleração 0 => velocidade constante)

func predict(_mi, _S, _A, _B, _u, _R) -> void:
	''' Função de predição '''
	
	var mi_pred = _A * _mi + _B* _u             # média estimada
	var S_pred = _A * _S * _A.transpose() + _R  # covariância estimada
	
	return 

func correction(mi_pred, S_pred, C, Q, z) -> void:
	''' Função de correção '''
	
	#variáveis que serão armazenadas p/ próxima iteração (se tornará o t-1)
	var K = S_pred * C.transpose() * (C * S_pred * C.transpose() + Q).inverse() # ganho de kalman
	var mi_new = mi_pred + K * (z - C * mi_pred)  # média corrigida
	var S_new = S_pred - K * C * S_pred  # correlação corrigida
	
	return
	

	








''' const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide() '''










