extends CharacterBody3D

var PlyFuncs: Node

var speed
const SPEED_SPRINT = 8.0
const SPEED_WALK = 4.0
const JUMP_VELOCITY = 4.5
var gravity = Vector3(0, -9.8, 0) # 9.8 is the default

@export var hp: int = 90
@export var last_damage = 0.0
const HP_MAX = 100
const HP_TIME_UNTIL_REGEN = 2
const HP_DELAY_BETWEEN_REGEN = 0.2

var direction := Vector3.ZERO
var jump: bool = false
var sprint: bool = false

signal hp_changed

@onready var head = $Head
@onready var camera = $Head/Camera3D

func _ready() -> void:
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	var id: int = multiplayer.get_unique_id()
	var char_id = name
	
	if( int( char_id.replace("ply_", ""))  == id ):
		camera.current = is_multiplayer_authority()
		
func _process(delta: float) -> void:
	if last_damage < HP_TIME_UNTIL_REGEN:
		last_damage += delta
	elif hp < HP_MAX:
		hp += 1
		last_damage = HP_TIME_UNTIL_REGEN - HP_DELAY_BETWEEN_REGEN
		emit_signal("hp_changed")

func _physics_process(delta: float) -> void:
	
	if not is_multiplayer_authority():
		return
		
	if Input.is_action_just_pressed("quit"):
		$"../".exit_game(name.to_int())
		get_tree().quit()

	# Add the gravity.
	if not is_on_floor():
		velocity += gravity * delta

	# Handle jump.
	if jump and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	#Handle Sprint
	if sprint:
		speed = SPEED_SPRINT
	else: 
		speed = SPEED_WALK

	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed 
		else:
			velocity.x = 0.0
			velocity.z = 0.0
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 2.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 2.0)
	
	#direction = Vector3.ZERO
	jump = false

	move_and_slide()

@rpc("any_peer", "call_remote", "reliable")
func sv_use(item_name: String):
	var ply_id: int = multiplayer.get_remote_sender_id()
	var charac: Node = PlyFuncs.get_char_from_id(ply_id)

	var item: Node = get_node_or_null("/root/Main/Items/" + str(item_name))
	if item and is_instance_valid(item) and multiplayer.is_server():
		#var ply_id: int = multiplayer.get_remote_sender_id()
		#var ply: Node = get_node_or_null("/root/Main/Players/" + str(ply_id))
		item.on_use( charac )
		
		
@onready var spawn_point: Marker3D = get_node_or_null("/root/Main/SpawnPoint")

func kill():
	position = spawn_point.position
	hp = 90
	last_damage = 0
	
func heal(amt: int):
	hp = clamp( hp + amt, 0, HP_MAX )
	
func take_damage(dmg: int, _inflictor: Node):
	last_damage = 0
	hp = clamp( hp - dmg, 0, HP_MAX )
	if hp <= 0: kill()

func on_use(char):
	take_damage(20, char)
