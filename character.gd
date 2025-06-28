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

var direction := Vector3.ZERO
var jump: bool = false
var sprint: bool = false

func _physics_process(delta: float) -> void:
	
	if not is_multiplayer_authority():
		return
	
	#camera.rotation.x = pitch
	
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
		
	#viewbob
	vb_sin += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = headbob(vb_sin)
	
	# FOV
	var velocity_clamped = clamp(velocity.length(), 0.5, SPEED_SPRINT * 2)
	var target_fov = FOV_BASE + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	
	#direction = Vector3.ZERO
	jump = false
	sprint = false

	move_and_slide()
	
func headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * vb_frequency) * vb_amp
	pos.x = cos(time * vb_frequency / 2) * vb_amp
	return pos
	
# A player using an entity
func use():
	var ent = cast_ray()

	if ent != null and ent.has_method("on_use"):
		rpc_id(1, "sv_use", ent.name)  # 1 = server
		#queue_free()

func cast_ray():
	var from = camera.global_position
	var to = from + camera.global_transform.basis.z * -USE_RANGE  # negative Z is forward

	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [self]

	var result = space_state.intersect_ray(query)
	if result and result.collider:
		return result.collider

@rpc("any_peer", "call_remote", "reliable")
func sv_use(item_name: String):
	var ply_id: int = multiplayer.get_remote_sender_id()
	var ply: Node = get_node_or_null("/root/Main/Players/" + str(ply_id))

	var item: Node = get_node_or_null("/root/Main/Items/" + str(item_name))
	if item and is_instance_valid(item) and multiplayer.is_server():
		#var ply_id: int = multiplayer.get_remote_sender_id()
		#var ply: Node = get_node_or_null("/root/Main/Players/" + str(ply_id))
		item.on_use( ply )
