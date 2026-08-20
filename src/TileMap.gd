extends TileMap

var moisture = FastNoiseLite.new()
var temperature = FastNoiseLite.new()
var altitude = FastNoiseLite.new()
var width = 80  # aproimadamente 1080
var height = 48 # aproximadamente 720
@onready var sensor = get_parent().get_child(0).get_child(2)
@onready var bond = get_parent().get_child(0).get_child(1)
@onready var eye_kalman = get_parent().get_child(0).get_child(0)


#Choice random for alt > 4
var alt_x = randi_range(0,2)
var alt_y = randi_range(0,1)
#################
var alt_water_surface = randi_range(1,3)

###### setando posição aleatória do forte
var pos_x_random = randi_range(0,width-1)
var pos_y_random = randi_range(0,height-1)
var pos_vector = Vector2i(pos_x_random-width, pos_y_random-height)
@onready var city_generation = get_parent().get_child(3)
#######################################
var min_distance = 520
###############################################

############## setando posição do persongame ############
var bond_option = randi_range(0, 3)  # 0: upper; 1: down; 2: left; 3: right
var position_map = {
	0: Vector2(randf_range(-639, 639), -359),
	1: Vector2(randf_range(-639, 639), 359),
	2: Vector2(-639, randf_range(-359, 359)),
	3: Vector2(639, randf_range(-359, 359))
}
#########################################################
var bond_num_victories
func _ready():
	
	bond_num_victories = bond.num_victories
	var pos_x_random = randi_range(- get_viewport().size.x/2 + 15,  get_viewport().size.x/2 - 15) 
	var pos_y_random = randi_range(- get_viewport().size.y/2 + 15,  get_viewport().size.y/2 - 15)
	var pos_vector = Vector2i(pos_x_random - width, pos_y_random - height)
	
	#### setando o tamanho da tela 
	#set_viewport().size.x = 1280
	print(get_viewport().size.y, get_viewport().size.x)
	city_generation.position = pos_vector
	sensor.position = Vector2i(pos_vector[0]+64,pos_vector[1]+ 64) #ajeitando para o centro do forte
	eye_kalman.position = Vector2i(pos_vector[0]+64,pos_vector[1]+ 64)
	
	moisture.seed = randi()   #seed umidade
	temperature.seed = randi()  #seed temperatura
	altitude.seed = randi()    #seed altitude
	
	var distance_bond_fort = position_map[bond_option].distance_to(pos_vector)
	
	print(distance_bond_fort)
	if distance_bond_fort < min_distance:
		bond_option = randi_range(0, 3) #seleção entre os sides de nascimento
		print('nn foi')
		return _ready()
	else:
		bond.position = position_map[bond_option]
	
func _process(_delta) -> void:
	generate_chunk(Vector2(0,0))   #bond.position
	check_tile_effect() #efeito de tile
	'print(bond.positiossan)'
	#print('tempo faltando: ',time_hability.time_left)

func check_tile_effect() -> void:
	''' Função que analisa o tile do persongem e aplica seu efeito '''
	
	var bond_tile = local_to_map(bond.position) # Obtém as coordenadas do tile atual do "Bond" no mapa
	var cell_item_id_0 = get_cell_atlas_coords(0, bond_tile) #indentifica qual é a tile atlas utilizada no tile 0
	#var cell_item_id_1 = get_cell_atlas_coords(1, bond_tile) #indentifica qual é a tile atlas utilizada no tile 1
	var dict_atlas_coord = { # index=0 é efeito de velocidade, index=1 é desvio padrão no filtro
		Vector2i(3,0): [0.4,0.2] , # Reduz a velocidade do "Bond" em 40%
		Vector2i(3,1): [0.6,0.15] , 
		Vector2i(3,2): [0.8,0.15] ,
		Vector2i(3,3): [0.9,0.05] ,
		Vector2i(0,0): [0.6,0.1] ,
		Vector2i(0,1): [0.6,0.1] ,
		Vector2i(1,0): [0.6,0.1] ,
		Vector2i(2,0): [1.3,0.2] ,
		Vector2i(1,1): [1.1,0.2] ,
		Vector2i(2,1): [1.1,0.2] ,
		Vector2i(0,2): [1,0.1] ,
		Vector2i(1,3): [1,0.1] ,
		Vector2i(0,3): [1,0.1] ,
		Vector2i(2,3): [1,0.2] ,
		Vector2i(1,2): [1,0.05] ,
		Vector2i(2,2): [1,0.05] 
	}
	if cell_item_id_0 in dict_atlas_coord.keys():
		bond.velocity *= dict_atlas_coord[cell_item_id_0][0]
		sensor.factor_ruido = dict_atlas_coord[cell_item_id_0][1]
		eye_kalman.std_meas = dict_atlas_coord[cell_item_id_0][1] 
		eye_kalman.std_acc = dict_atlas_coord[cell_item_id_0][1]#std_acc
		eye_kalman.noise_observation = dict_atlas_coord[cell_item_id_0][1]
		#print(bond.velocity)
	
################################### Print_once ##########################################
var hasPrinted: bool = false #variavel para definir se já foi printado
func print_once(value, type=false) -> void:
	
	if not hasPrinted and not type:
		hasPrinted = true
		print(len(value))
	if not hasPrinted and type:
		hasPrinted = true
		print(value)
####################################################################################



func generate_chunk(position) -> void:
	var tile_pos = local_to_map(position)
	var list_cells = []  ## a fazer: definirá se irá nevar
		
	for x in range(width):
		for y in range(height):
			var moist = moisture.get_noise_2d(tile_pos.x - width/2 + x, tile_pos.y - height/2 + y)*10
			var temp = temperature.get_noise_2d(tile_pos.x - width/2 + x, tile_pos.y - height/2 + y)*10
			var alt = altitude.get_noise_2d(tile_pos.x - width/2 + x, tile_pos.y - height/2 + y)*10
			
			#if pos_x_random == x and pos_y_random == y:
				#set_cell(0, Vector2i(pos_x_random - width/2 + x, pos_y_random - height/2 + y), 2, Vector2i(4, 4))
			
			if alt <=-4:
				set_cell(0, Vector2i(tile_pos.x-width/2 + x, tile_pos.y-height/2 + y), 0, Vector2(3, 0))
			
			elif alt >-4 and alt <=-2:
				set_cell(0, Vector2i(tile_pos.x-width/2 + x, tile_pos.y-height/2 + y), 0, Vector2(3,alt_water_surface ))
				
			elif alt > 4:
				set_cell(0, Vector2i(tile_pos.x-width/2 + x, tile_pos.y-height/2 + y), 0, Vector2i(alt_x, alt_y))
				list_cells.append('snow')
				
			elif alt > 3 and alt <= 4:
				set_cell(0, Vector2i(tile_pos.x-width/2 + x, tile_pos.y-height/2 + y), 1, Vector2i(3, 0))
			
			else:
				if temp < -3:
					if round(temp) == 5:
						set_cell(0, Vector2i(tile_pos.x-width/2 + x, tile_pos.y-height/2 + y), 1, Vector2(1,1))
					else:
						set_cell(0, Vector2i(tile_pos.x-width/2 + x, tile_pos.y-height/2 + y), 1, Vector2(2,1))
				else:
					if bond_num_victories > 5: 
						set_cell(0, Vector2i(tile_pos.x-width/2 + x, tile_pos.y-height/2 + y), 1, Vector2(round((moist+10)/5), round((temp+10)/5)))
					else:
						set_cell(0, Vector2i(tile_pos.x-width/2 + x, tile_pos.y-height/2 + y), 0, Vector2(round((moist+10)/5), round((temp+10)/5)))
			list_cells.append('something')
	
	
	print_once([list_cells.count('snow'), len(list_cells), "posição do forte (x,y): ", pos_x_random-width/2, pos_y_random-height/2], true)


func _input(event):
	if event.is_action_pressed("reload"):
		get_tree().reload_current_scene()
	
	if event.is_action_pressed("hability") and not bond.hability and $Timer.time_left == 0:
		bond.hability = true
		$Timer.start()
		sensor.hab_bool = false
			




func _on_area_detect_body_entered(_body):
	if _body.is_in_group('Invaders') :
		var pts = 100-get_child(0).percent
		# current_score é uma tabela do tipo acumulador
		SilentWolf.Scores.save_score("Pontuação atual", pts, "current_score")
		
		#var sw_result = await SilentWolf.Scores.get_scores(0, "current_score").sw_get_scores_complete
		print('Vitória')
		#print(sw_result.scores[0].score)
		#eye_kalman.points += 1
		#print(eye_kalman.points)
		$Timer.stop()
		bond.hability = false
		sensor.hab_bool = true
		get_tree().reload_current_scene()
		


func _on_timer_timeout():
	$Timer.stop()
	sensor.hab_bool = true
	print('tempo de habilidade esgotado')
