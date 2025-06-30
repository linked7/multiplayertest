extends CharacterBody3D

class_name Character

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
const SHOOT_COOLDOWN = 1.0

var last_shot: bool = 0.0
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
	
	# Add the gravity.
	if not is_on_floor():
		velocity += gravity * delta
	elif jump:
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

@onready var spawn_point: Marker3D = get_node_or_null("/root/Main/SpawnPoint")

func kill():
	position = spawn_point.position
	hp = 90
	last_damage = 0

func heal(amt: int):
	hp = clamp( hp + amt, 0, HP_MAX )
	
func take_damage(dmg: int, _inflictor: Node, origin: Vector3):
	last_damage = 0
	hp = clamp( hp - dmg, 0, HP_MAX )
	var dir = (position - origin).normalized()
	velocity += dir * ( round(dmg) / 2 )
	if hp <= 0: kill()

func on_use(chara):
	take_damage(15, chara, chara.position)
