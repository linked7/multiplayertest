extends Node3D

var input_vector := Vector2.ZERO
var jump_pressed := false
var sprinting := false
var use_pressed := false
var quit_pressed := false
var mouse_delta := Vector2.ZERO

var has_camera := false

func _ready() -> void:
	pass
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		mouse_delta = event.relative  # Accumulate per frame

func _process(_delta: float) -> void:
	var id: int = multiplayer.get_unique_id()
	
	if not has_camera:
		var cam: Node = get_node_or_null("../../char_" + str(id) + "/Head/Camera3D")
		if cam:
			cam.current = true
			has_camera = true
	
	if id == 1:
		return
	
	var input_state = {
		"move": Input.get_vector("move_left", "move_right", "move_forward", "move_back"),
		"jump": Input.is_action_just_pressed("move_jump"),
		"sprint": Input.is_action_pressed("move_sprint"),
		"use": Input.is_action_just_pressed("use"),
		"quit": Input.is_action_just_pressed("quit"),
		"mouse": mouse_delta
	}
	rpc_id(1, "send_inputs", input_state)
	
	# mouse relesing
	if Input.is_action_just_pressed("camera"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	if Input.is_action_just_released("camera"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

@rpc("any_peer", "call_remote", "unreliable")
func send_inputs(inputs: Dictionary):
	var id: int = multiplayer.get_remote_sender_id()
	var character = get_node("../../char_" + str(id) )
	
	if inputs["move"]:
		character.move_vec = inputs["move"]
	character.jump = inputs["jump"] or false
	character.sprint = inputs["sprint"] or false
	character.use_net = inputs["use"] or false
	if inputs["mouse"]:
		character.mouse_delta = inputs["mouse"]
		print("mouse data sent")
