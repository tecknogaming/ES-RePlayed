extends CharacterBody2D

enum MovementModes {
	FreeRoam,
	GridLocked
}

enum States {
	Idle,
	Walk
}

enum Directions { UP, DOWN, LEFT, RIGHT, UL, UR, DL, DR, }

enum Charcters {
	Jolteon
}

var IDIR = [ "UP", "DOWN", "LEFT", "RIGHT", "UL", "UR", "DL", "DR" ]
var ISTA = [ "IDLE", "WALK" ]
var ICHA = [ "Jolteon" ]

@export_category("Movement")
@export var MOVEMENT_MODE := MovementModes.FreeRoam
@export var SPEED := 60.0

@export_category("GridMovememnt")
@export var Terrain: TileMap
@export var GSPEED := .5

@export_category("Sates")
@export var current_state     := States.Idle
@export var current_direction := Directions.DOWN
@export var current_character := Charcters.Jolteon

var current_sprite_node: AnimatedSprite2D
var tiles = []
var isMoving = false

func _ready():
	_get_tiles()
	_process_sprite()
	_fix_grid_pos()

func _physics_process(delta):
	if MOVEMENT_MODE == MovementModes.FreeRoam:
		velocity = Vector2.ZERO
		if Input.is_action_pressed("up"):
			velocity.y -= SPEED
		elif Input.is_action_pressed("down"):
			velocity.y += SPEED
		
		if Input.is_action_pressed("left"):
			velocity.x -= SPEED
		elif Input.is_action_pressed("right"):
			velocity.x += SPEED
		
		velocity = velocity.normalized() * SPEED
		move_and_slide()
		
		if velocity != Vector2.ZERO:
			
			current_sprite_node.speed_scale = 1
			current_state = States.Walk
			_process_direction()
			_process_sprite()
		else:
			current_sprite_node.speed_scale = .3
			current_state = States.Idle
			_process_direction()
			_process_sprite()
			
	elif MOVEMENT_MODE == MovementModes.GridLocked:
		
		if !isMoving:
			if Input.is_action_pressed("up") and Input.is_action_pressed("left"):
				_grid_move(Directions.UL)
				current_direction = Directions.UL
			elif Input.is_action_pressed("up") and Input.is_action_pressed("right"):
				_grid_move(Directions.UR)
				current_direction = Directions.UR
			elif Input.is_action_pressed("down") and Input.is_action_pressed("left"):
				_grid_move(Directions.DL)
				current_direction = Directions.DL
			elif Input.is_action_pressed("down") and Input.is_action_pressed("right"):
				_grid_move(Directions.DR)
				current_direction = Directions.DR
			
			elif Input.is_action_pressed("up"):
				_grid_move(Directions.UP)
				current_direction = Directions.UP
			elif Input.is_action_pressed("down"):
				_grid_move(Directions.DOWN)
				current_direction = Directions.DOWN
			elif Input.is_action_pressed("left"):
				_grid_move(Directions.LEFT)
				current_direction = Directions.LEFT
			elif Input.is_action_pressed("right"):
				_grid_move(Directions.RIGHT)
				current_direction = Directions.RIGHT
			
			_process_sprite()
		else:
			_process_sprite()

func _fix_grid_pos():
	global_position = Terrain.to_global(Terrain.map_to_local(Terrain.local_to_map(Terrain.to_local(global_position))))

func _grid_move(dir: Directions):
	if !isMoving:
		var tile = tiles[dir]
		var player_true_pos = Terrain.to_global(Terrain.map_to_local(tile[1]))
		print(tile)
		
		if tile[0] == true:
			isMoving = true
			var tween = get_tree().create_tween()
			current_state = States.Walk
			if [4,5,6,7].has(dir):
				await tween.tween_property(self, "global_position", player_true_pos, GSPEED + .2).finished
			else:
				await tween.tween_property(self, "global_position", player_true_pos, GSPEED).finished
			_get_tiles()
			isMoving = false
			current_state = States.Idle

func _get_tiles():
	if Terrain != null:
		var map_player_pos = Terrain.local_to_map(Terrain.to_local(global_position))
		
		# walkables
		_get_all_tiles(0, map_player_pos, true, false)
		# walls/trees
		_get_all_tiles(2, map_player_pos, false, true)
		_get_all_tiles(3, map_player_pos, false, true)
		_get_all_tiles(4, map_player_pos, false, true)

func _get_all_tiles(layer: int, player_pos: Vector2, valift: Variant, valifs: Variant):
	tiles = [[], [], [], [], [], [], [], []]
	#top
	if Terrain.get_cell_source_id(layer, player_pos + Vector2(0, -1)) != -1:
		tiles[0] = [valift, player_pos + Vector2(0, -1)]
	else:
		tiles[0] = [valifs, player_pos + Vector2(0, -1)]
	#top-right
	if Terrain.get_cell_source_id(layer, player_pos + Vector2(1, -1)) != -1:
		tiles[5] = [valift, player_pos + Vector2(1, -1)]
	else:
		tiles[5] = [valifs, player_pos + Vector2(1, -1)]
	#right
	if Terrain.get_cell_source_id(layer, player_pos + Vector2(1, 0)) != -1:
		tiles[3] = [valift, player_pos + Vector2(1, 0)]
	else:
		tiles[3] = [valifs, player_pos + Vector2(1, 0)]
	#down-right
	if Terrain.get_cell_source_id(layer, player_pos + Vector2(1, 1)) != -1:
		tiles[7] = [valift, player_pos + Vector2(1, 1)]
	else:
		tiles[7] = [valifs, player_pos + Vector2(1, 1)]
	#down
	if Terrain.get_cell_source_id(layer, player_pos + Vector2(0, 1)) != -1:
		tiles[1] = [valift, player_pos + Vector2(0, 1)]
	else:
		tiles[1] = [valifs, player_pos + Vector2(0, 1)]
	#down-left
	if Terrain.get_cell_source_id(layer, player_pos + Vector2(-1, 1)) != -1:
		tiles[6] = [valift, player_pos + Vector2(-1, 1)]
	else:
		tiles[6] = [valifs, player_pos + Vector2(-1, 1)]
	#left
	if Terrain.get_cell_source_id(layer, player_pos + Vector2(-1, 0)) != -1:
		tiles[2] = [valift, player_pos + Vector2(-1, 0)]
	else:
		tiles[2] = [valifs, player_pos + Vector2(-1, 0)]
	#top-left
	if Terrain.get_cell_source_id(layer, player_pos + Vector2(-1, -1)) != -1:
		tiles[4] = [valift, player_pos + Vector2(-1, -1)]
	else:
		tiles[4] = [valifs, player_pos + Vector2(-1, -1)]

func _process_sprite():
	if current_sprite_node != get_node("sprites/" + ICHA[current_character]):
		current_sprite_node = get_node("sprites/" + ICHA[current_character])
	
	if current_state == States.Walk:
		if MOVEMENT_MODE == MovementModes.FreeRoam:
			current_sprite_node.speed_scale = .3
		elif MOVEMENT_MODE == MovementModes.GridLocked:
			current_sprite_node.speed_scale = .8
	elif current_state == States.Idle:
		current_sprite_node.speed_scale = .3
	
	current_sprite_node.play(IDIR[current_direction]+"-"+ISTA[current_state])
func _process_direction():
	if velocity.y > 0:
		current_direction = Directions.DOWN
	elif velocity.y < 0:
		current_direction = Directions.UP
	elif velocity.x > 0:
		current_direction = Directions.RIGHT
	elif velocity.x < 0:
		current_direction = Directions.LEFT
	
	if velocity.y > 0 and velocity.x > 0:
		current_direction = Directions.DR
	elif velocity.y > 0 and velocity.x < 0:
		current_direction = Directions.DL
	elif velocity.y < 0 and velocity.x > 0:
		current_direction = Directions.UR
	elif velocity.y < 0 and velocity.x < 0:
		current_direction = Directions.UL
