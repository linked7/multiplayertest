extends Node3D

class_name Controller

var PlyFuncs: Node

const FOV_BASE = 75.0
const FOV_CHANGE = 1.5
const USE_RANGE = 2.5
var vb_frequency = 8.0
var vb_amp = 0.04
var vb_sin = 0.0

var input_vector := Vector2.ZERO
var jump_pressed := false
var sprinting := false
var mouse_delta := Vector2.ZERO
var yaw: float = 0.0

var has_camera = false
var head: Node
var character: Node

const SHOOT_COOLDOWN = 1.0
var last_shoot = 0

const RAY_ENT = 0
const RAY_POS = 1

func _ready() -> void:
	PlyFuncs = get_node("/root/Main/PlayerFuncs")
	pass

func _process(delta: float) -> void:
	var id: int = multiplayer.get_unique_id()
	
	if id == 1:
		return
		
	if not has_camera:
		var cam: Node = get_node_or_null("../../char_" + str(id) + "/Head/Camera3D")
		character = get_node_or_null("../../char_" + str(id))
		if cam:
			cam.current = true
			has_camera = cam
			
	var direction := Vector3.ZERO
	var move_vec = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	
	if head:
		yaw = head.rotation.y
		direction = (head.transform.basis * Vector3(move_vec.x, 0, move_vec.y)).normalized()
	else:
		head = get_node_or_null("../../char_" + str(multiplayer.get_unique_id()) + "/Head")
		

	var input_state = {
		"move": direction,
		"jump": Input.is_action_pressed("move_jump"),
		"sprint": Input.is_action_pressed("move_sprint"),
		"yaw": yaw
	}
	rpc_id(1, "send_inputs", input_state)
	
	# mouse relesing
	if Input.is_action_just_pressed("camera"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	if Input.is_action_just_released("camera"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
	if Input.is_action_just_pressed("use"):
		var hit = cast_ray(RAY_ENT)
		print(type_string(typeof(hit)))
		if hit and type_string(typeof(hit)):
			rpc_id(1, "sv_use", hit.get_path())
	
	if Input.is_action_just_pressed("attack"):
		last_shoot += delta
		var hit = cast_ray(RAY_POS)
		if hit:
			last_shoot = 0.0
			rpc_id(1, "sv_shoot", hit)
			print("Requesting boom")
	
	# FOV
	if has_camera:
		var movement_strength = clamp(move_vec.length(), 0.0, 1.0)  # length of input vector
		var target_fov = FOV_BASE + FOV_CHANGE * movement_strength
		has_camera.fov = lerp(has_camera.fov, target_fov, delta * 8.0)
		vb_sin += delta * move_vec.length() * float(character.is_on_floor())
		has_camera.transform.origin = headbob(vb_sin)

func headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * vb_frequency) * vb_amp
	pos.x = cos(time * vb_frequency / 2) * vb_amp
	return pos
	
@rpc("any_peer", "call_remote", "unreliable")
func sv_shoot(target: Vector3):
	#if last_shoot < SHOOT_COOLDOWN: return
	last_shoot = 0.0
	character = PlyFuncs.get_char_from_id(multiplayer.get_remote_sender_id())
	var from = character.get_node("Head").position
	var to = target
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [character]

	var result = space_state.intersect_ray(query)
	var pos = result.get("position", null)
	if not ( result or pos): return
	var radius = 5.0
	explode( pos, radius, 40, character)
	print("Boom accepted")
	
var explosion_scene: PackedScene = load("res://effect_explosion.tscn")

func explode(pos: Vector3, radius: float, damage: int, inflictor: Character ):
	var victims = PlyFuncs.get_chars_in_sphere( pos, radius )
	var effect = explosion_scene.instantiate()
	
	effect.position = pos
	get_node("../../../Items").add_child(effect, true)
	effect.get_node("GPUParticles3D").emitting = true

	for chara: Character in victims:
		var dist: float = chara.position.distance_to( pos )
		var diff: float = clampf(dist / radius, 0, 1 ) 
		damage = round( damage * (1 - diff ) )
		chara.take_damage( damage, inflictor, pos )
	
@rpc("any_peer", "call_remote", "unreliable")
func sv_use(ent_path: NodePath):
	var ent := get_node_or_null(ent_path)
	if not (ent or ent.on_use): return
	character = PlyFuncs.get_char_from_id(multiplayer.get_remote_sender_id())

	if not character:
		return
	var char_pos: Vector3 = character.get_node("Head").global_position
	var distance = char_pos.distance_to(ent.global_position)
	
	if distance > USE_RANGE: return
	ent.on_use(character)

@rpc("any_peer", "call_remote", "unreliable")
func send_inputs(inputs: Dictionary):
	var id: int = multiplayer.get_remote_sender_id()
	character = get_node_or_null("../../char_" + str(id) )
	
	if inputs["move"]:
		character.direction = inputs["move"]
	else: #This is nessicary because Vector3.ZERO becomes false when sent over rpc call
		character.direction = Vector3.ZERO
	character.jump = inputs["jump"] or false
	character.sprint = inputs["sprint"] or false
	character.get_node("Head").rotation.y = inputs["yaw"]

func cast_ray(type):
	if !has_camera: return
	var from = has_camera.global_position
	var to = from + has_camera.global_transform.basis.z * -USE_RANGE  # negative Z is forward
	if type == RAY_POS:
		to = from + has_camera.global_transform.basis.z * -500

	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [self]

	var result = space_state.intersect_ray(query)
	if result:
		var ent = result.get("collider", null)
		var pos = result.get("position", null)
		match type:
			RAY_ENT:
				return ent
			RAY_POS:
				return pos
	return
	
func use():
	var ent = cast_ray(RAY_ENT)

	if ent != null and ent.has_method("on_use"):
		rpc_id(1, "sv_use", ent.get_path)
