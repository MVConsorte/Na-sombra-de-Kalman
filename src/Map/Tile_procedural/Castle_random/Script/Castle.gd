extends TileMap
var fortPosition = Vector2(0,0) # posição geral do forte
var tileSize = Vector2(16, 16)  # Tamanho do tile
var fortSize = Vector2(8, 8)  # Tamanho do forte em tiles

@onready var area2d = Area2D.new()  # Área de contato

func _ready():
	generateFort()

func generateFort():
	var fortMap = []
	
	# Gerar o mapa do forte
	for y in range(fortSize.y):
		var row = []
		for x in range(fortSize.x):
			################## definindo as pontas do muro ####
			if x == 0 and y == 0:
					row.append(44)  
			elif x==0 and y == fortSize.y-1:
					row.append(41)
			elif x== fortSize.x - 2 and y == fortSize.y-1:
					row.append(42)
			elif x== fortSize.x - 2 and y == 0:
					row.append(43)
			####################################
			####### definindo laterais do muro  ###########
			if (x==0 or x==fortSize.x - 1) and not(y==0 or y == fortSize.y -1):
					row.append([31,31,31,34][randi_range(0,3)]) #  75% de vir muro vertical normal
			elif (y==0 or y==fortSize.y - 1) and not(x== fortSize.x - 1 and y == 0):
				row.append([32,32,32,33][randi_range(0,3)]) #  75% de vir muro horizontal normal
			####################################
			
			else:
				row.append([12,13,14,21,22,22,22,23,24][randi_range(0,8)])
				
		fortMap.append(row)

	# Gerar paredes internas
	for i in range(round(fortSize.x * fortSize.y / 50)):
		var x = randi_range(1, fortSize.x - 2)
		var y = randi_range(1, fortSize.y - 2)
		fortMap[y][x] = 21
	
	# Gerar centro de forte
	for i in [[0,0],[0,-1],[-1,0],[-1,-1]]:
		fortMap[round(fortSize.y/2+i[0])][round(fortSize.x/2+i[1])] = 11#randi_range(6,8)

	var dict_intern_space = {
		11: Vector2i(0, 0), 13: Vector2i(2, 0),
		21: Vector2i(0, 1), 23: Vector2i(2, 1),
		31: Vector2i(0, 2), 33: Vector2i(2, 2),
		41: Vector2i(0, 3), 43: Vector2i(2, 3),
		12: Vector2i(1, 0), 14: Vector2i(3, 0),
		22: Vector2i(1, 1), 24: Vector2i(3, 1),  #tile específico de centro de forte
		32: Vector2i(1, 2), 34: Vector2i(3, 2),  #tile específico de centro de forte
		42: Vector2i(1, 3), 44: Vector2i(3, 3)  #tile específico de centro de forte
	}
	
	'# Renderizar o mapa
	for y in range(fortSize.y):
		for x in range(fortSize.x):
			var tileId = fortMap[y][x]
			var tileTransform = Transform2D()
			var rotationDegrees = randi_range(0, 3) * 90  # Rotacionar o tile em 0, 90, 180 ou 270 graus
			tileTransform = tileTransform.rotated(rotationDegrees)
			set_cell(0, Vector2i(x, y), 1, dict_intern_space[tileId])'
	
	################## definindo as pontas do muro ####
	set_cell(0, Vector2i(0+fortPosition[1], 0 + fortPosition[0]), 1, dict_intern_space[44])
	set_cell(0, Vector2i(0+fortPosition[1], fortSize.y-1 + fortPosition[0]), 1, dict_intern_space[41])
	set_cell(0, Vector2i(fortSize.x-2 +fortPosition[1], fortSize.y-1 + fortPosition[0]), 1, dict_intern_space[42])
	set_cell(0, Vector2i(fortSize.x-2 + fortPosition[1], 0 + fortPosition[0]), 1, dict_intern_space[43])
	####################################
	
	# Renderizar o mapa
	for y in range(fortSize.y):
		for x in range(fortSize.x):
			set_cell(0, Vector2i(x + fortPosition[1], y + fortPosition[0]), 1, dict_intern_space[fortMap[y][x]])


func _input(event):
	if event.is_action_pressed("reload"):
		get_tree().reload_current_scene()


