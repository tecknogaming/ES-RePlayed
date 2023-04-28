extends CharacterBody2D

enum MovementModes {
	FreeRoam,
	GridLocked
}

enum States {
	Idle,
	Walk
}

enum Directions { UP, DOWN, LEFT, RIGHT, UL, UR, DL, DR }

enum Charcters {
	Jolteon
}

var IDIR = [ "UP", "DOWN", "LEFT", "RIGHT", "UL", "UR", "DL", "DR" ]
var ISTA = [ "IDLE", "WALK" ]
var ICHA = [ "Jolteon" ]

enum Temp {
	new,
	old
}

@export_category("Movement")
@export var ACTIVE        := true
@export var MOVEMENT_MODE := MovementModes.FreeRoam
@export var SPEED         := 60.0

@export_category("GridMovememnt")
@export var Terrain: TileMap
@export var type := Temp.old
@export var GSPEED := .5
@export var TileSize := 16

@export_category("Sates")
@export var current_state     := States.Idle
@export var current_direction := Directions.DOWN
@export var current_character := Charcters.Jolteon

var current_sprite_node: AnimatedSprite2D
var isMoving = false

var grid_raycast
var grid_dir = [
	Vector2(0,-1),  #left
	Vector2(0,1),  #right
	Vector2(-1,0), #up
	Vector2(1,0),  #down
	Vector2(-1,-1), #up-left
	Vector2(1,-1),  #down-left
	Vector2(-1,1), #up-right
	Vector2(1,1),  #down-right
]

func _ready():
	grid_raycast = $RayCast2D
	
	_process_sprite()
	_fix_grid_pos()

func _physics_process(delta):
	if ACTIVE:
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
		grid_raycast.target_position = grid_dir[dir] * TileSize
		grid_raycast.force_raycast_update()
		print(grid_raycast.is_colliding())
		if !grid_raycast.is_colliding():
			var player_new_pos = global_position + grid_dir[dir] * TileSize
			var tween = create_tween()
			isMoving = true
			current_state = States.Walk
			if [4,5,6,7].has(dir):
				await tween.tween_property(self, "global_position", player_new_pos, GSPEED + .2).finished
			else:
				await tween.tween_property(self, "global_position", player_new_pos, GSPEED).finished
			isMoving = false
			current_state = States.Idle

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
