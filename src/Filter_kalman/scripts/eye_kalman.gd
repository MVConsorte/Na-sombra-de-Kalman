extends CharacterBody2D

class_name Eye_kalman

@onready var ProceduralGen = get_parent().get_child(0)

var points = 0
var _Bond_ref = null
@export var percent = 0
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
		#print(timer.time_left)
		if timer.timeout:
			percent += 10
			#print(percent)


func _on_real_view_body_exited(body):
	in_real_colision = false
	timer.stop()
		
var percent_value = randi_range(5,7)
func _on_timer_timeout():
	if in_real_colision:
		percent += 10
		#print(percent_value)	
	set_physics_process(true)
	
var factor_ruido = 0
func _physics_process(_delta: float) -> void:
	_animate()
	if _Bond_ref != null:
		var _direction: Vector2 = global_position.direction_to(Vector2(mi_pred[0][0], mi_pred[1][0])).normalized()
		velocity = _direction * 150
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
	"Pontuação: {0} ".format([points])
	_animation.play("100_percent_view")	
	get_tree().change_scene_to_file("res://Screens/death_screen.tscn")  #se chegar a 100, perde
	
	return





# receber vetor de estado (2x2) - Linha1: posição; Linha2: velocidade
# receber entradas de controle (1x2) - aceleração de x, de y

# parâmetros constantes
var dt = 1 # número de atualizações por intervalo --> definido pelo sensor
#tempo de simulação: até atingir 100% de visibilidade

# processo / predição
var _A = [[1, 0,dt,0],[0,1,0,dt],[0,0,1,0],[0,0,0,1]]  #[[1,dt],[0,1]] 
var _B = [[dt**2/2, 0],[0,dt**2/2],[dt,0],[0,dt]] #4x2 #[[dt**2/2], [dt]]

var std_meas: float = 0.1  #desvio padrão da posição
#var sigma_v 0.1	#desvio padrão da velocidade
var _R = [[std_meas**2,0],[0,std_meas**2]]#[[sigma_d**2,0,0,0],[0,sigma_v**2,0,0],[0,0,sigma_d**2,0],[0,0,0,sigma_d**2]]    #ruido de medida: CovariÂncia

#Observação / Correção
var C = [[1,0,0,0],[0,1,0,0]]  # [[1,0],[0,1]]   

var std_acc = 0.1  #desvio padrão do processo
#var sigma_l = []  #[[0.5, 0], [0, 0.5]]	#Desvio padrão de l (dist)
var Q =  const_x_matrix([[dt**4/4, 0, dt**3/2, 0],[0, dt**4/4, 0, dt**3/2],[dt**3/2, 0, dt**2, 0],[0, dt**3/2, 0, dt**2]], std_acc**2) # multi(sigma_l, sigma_l)         #Covariância da observação

## Inicialização
	# v # velocidade inicial 
	# mi # Estado: posição (x,y - do forte); velocidade (0,0) 
	# S # Covariância do estado (inicialmente - perfeita ([0,0],[0,0])
	# u # aceleração (aceleração 0 => velocidade constante)
var _u = [[0],[0]] #aceleração x e aceleração y


func _on_ready():
	
	
	#print(inverse([[3,4,7,1],[1,1,1,2],[2,3,2,1],[0,4,0,7]]))
	#print(extract_inverse([[3,4,7,1],[1,1,1,2],[2,3,2,1],[0,4,0,7]],4))
	var _mi = [[0],[0],[0],[0]] #estado inicial & 4x1
	var _S = [[1,0,0,0],[0,1,0,0],[0,0,1,0],[0,0,0,1]] #covariancia inicial & 4x4
	
	predict(_mi, _S, _A, _B, _u, Q) # Chute inicial

var noise_observation = 0
func _on_sensor_read_data(_mi, _acceleration, _dt):
	#print(_acceleration) #'mi: ', _mi, ' dt: ', _dt, ' acele: ', 
	#_A = [[1,0,_dt,0],[0,1,0,dt],[0,0,1,0],[0,0,0,1]] 
	#_B = [[_dt**2/2, 0], [0, _dt**2/2], [_dt,0], [0,_dt]]
	_u[0] = [0]#[_acceleration]##
	_u[1] = [0]#[_acceleration]#[0]#
	_mi = [[_mi[0][0]],[_mi[0][1]]] # , [_mi[0][1]], [_mi[1][1]]
	#var _z = sum_matrix(_mi,const_x_matrix(_mi,randi_range(-1,1)*noise_observation))
	#print(mi_pred, _mi)
	correction(mi_pred, S_pred, C, _R, _mi)

var mi_pred
var S_pred

func predict(_mi, _S, _A, _B, _u, Q) -> void:
	''' Função de predição '''
	#print(_S)
	var At = transpose(_A) # 4x4 -> 4x4
	mi_pred = sum_matrix(dot(_A, _mi), dot(_B, _u))   # 4x4 dot 4x1 +  4x2 dot 2x1   # média estimada
	#print(dot(_A, _S), '      ', dot(dot(_A, _S), At), '            ', Q)
	S_pred = sum_matrix(dot(dot(_A, _S), At), Q) #((4x4 dot 4x4) dot 4x4) + 4x4 # covariância estimada
	#print(mi_pred,'    ', S_pred )
	#print(std_acc)
	return 

func correction(mi_pred, S_pred, C,_R, z) -> void:
	''' Função de correção '''
	
	#variáveis que serão armazenadas p/ próxima iteração (se tornará o t-1)
	var Ct = transpose(C)  #2x4 -> 4x2
	var S = sum_matrix(dot(dot(C, S_pred), Ct),_R) # S = C*s_pred*H' + R
	var K = dot(dot(S_pred, Ct), inverse(S)) # K = 4x2  # ganho de kalman
	#print(z)
	
	var mi_new = sum_matrix(mi_pred, dot(K, sum_matrix(z, dot(C, mi_pred), false))) # média corrigida
	var I = [[1,0,0,0],[0,1,0,0],[0,0,1,0],[0,0,0,1]]
	var S_new = dot(sum_matrix(I, dot(K, C), false), S_pred) #sum_matrix(S_pred, dot(dot(K, C), S_pred), false)  # correlação corrigida
	#print('K: ', K)
	predict(mi_new, S_new, _A, _B, _u, Q)
	
	return
	

	

######################## Operações com array #################################

func sum_matrix(A: Array, B: Array, sum = true):
	''' Função que realiza soma (sum=true) ou diferença (sum=false) entre matrizes '''
	var rows_a = len(A)
	var rows_b = len(B)
	var cols_a = len(A[0])
	var cols_b = len(B[0])
	var result = []
	
	if rows_a == rows_b and cols_a == cols_b:
		for row in range(rows_a):
			var new_row = []
			for col in range(cols_a):
				if sum:
					new_row.append(A[row][col] + B[row][col])
				else:
					new_row.append(A[row][col] - B[row][col])
			result.append(new_row)
		return result
	else:
		return 'Não é possível somar estas matrizes: A({0}x{1}) e B({2}x{3})'.format([rows_a, cols_a, rows_b, cols_b])

func const_x_matrix(matrix: Array, constant):
	var result = []
	if constant is float or constant is int:
		for row in matrix:
			var new_row = []
			for col in row:
				new_row.append(col * constant)
			result.append(new_row)
		return result
	
	return 'O fator de multiplicação não é válido. Tipo: {0}'.format([typeof(constant)])

func transpose(matrix: Array) -> Array:
	''' Retorna a tranposta de uma matriz ''' 
	var rows = len(matrix)
	var transposed = []
	if typeof(matrix[0]) == TYPE_ARRAY: #se o primeiro elemento for array, então há mais de uma linha
		var cols = len(matrix[0])
		for col in range(cols):
			var newRow = []
			for row in range(rows):
				newRow.append(matrix[row][col])
			transposed.append(newRow)
		return transposed
	
	var cols = rows
	rows = 1
	for col in range(cols):
		var newRow = []
		for row in range(rows):
			newRow.append(matrix[col])
		transposed.append(newRow)
	return transposed

func dot(A: Array, B: Array):
	var rows_a = len(A)
	var cols_a = len(A[0])
	var cols_b = len(B[0])
	var result = []
	
	if len(A[0]) != len(B):
		print('Não estabelecido as condições: ', A,'  ', B)
	else:
		for row in range(rows_a):
			var new_row = []
			
			for col in range(cols_b):
				var sum = 0
				
				for k in range(cols_a):
					#if cols_a != 1:
						#if cols_b != 1:
					sum += A[row][k] * B[k][col]
						#else:
							#sum += A[row][k] * B[k]
					#else:
						#if cols_b != 1:
							#sum += A[k] * B[k][col]
						#else:
							#sum += A[k] * B[k]
				
				new_row.append(sum)
			
			result.append(new_row)
		
		return result

################# inversa ######################
func inverse(matrix: Array) -> Array:
	var size = matrix.size()
	var augmentedMatrix = create_augmented_matrix(matrix)
	
	for i in range(size):
		var pivotRow = find_pivot_row(augmentedMatrix, i)
		if pivotRow == -1:
			print("A matriz não é inversível.")
			return []
		
		swap_rows(augmentedMatrix, i, pivotRow)
		divide_row(augmentedMatrix, i, augmentedMatrix[i][i])
		eliminate_rows(augmentedMatrix, i)
	
	var inverse = extract_inverse(augmentedMatrix, size)
	
	return inverse


func create_augmented_matrix(matrix: Array) -> Array:
	var size = matrix.size()
	var augmentedMatrix = []

	for i in range(size):
		var row = []
		for j in range(size):
			if i == j:
				row.append(1)
			else:
				row.append(0)
		augmentedMatrix.append(matrix[i] + row)

	return augmentedMatrix



func find_pivot_row(matrix: Array, col: int) -> int:
	var size = matrix.size()
	var maxRow = -1
	var maxVal = 0.0
	
	for i in range(col, size):
		if abs(matrix[i][col]) > maxVal:
			maxRow = i
			maxVal = abs(matrix[i][col])
	
	return maxRow


func swap_rows(matrix: Array, row1: int, row2: int) -> void:
	var temp = matrix[row1]
	matrix[row1] = matrix[row2]
	matrix[row2] = temp


func divide_row(matrix: Array, row: int, divisor: float) -> void:
	for i in range(matrix[row].size()):
		matrix[row][i] /= divisor


func eliminate_rows(matrix: Array, pivotCol: int) -> void:
	var size = matrix.size()
	
	for i in range(size):
		if i != pivotCol:
			var multiplier = matrix[i][pivotCol]
			for j in range(matrix[i].size()):
				matrix[i][j] -= multiplier * matrix[pivotCol][j]


func extract_inverse(matrix: Array, size: int) -> Array:
	var inverse = []
	
	for i in range(size):
		var row = []
		for j in range(size, matrix[i].size()):
			row.append(matrix[i][j])
		inverse.append(row)
	
	return inverse
	
################################################################################


