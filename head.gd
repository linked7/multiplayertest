extends Node3D

@onready var camera: Camera3D = $Camera3D
const SENSITIVITY = 0.003

func _unhandled_input(event: InputEvent) -> void:
	if multiplayer.get_unique_id() == 1: return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
