extends Node3D

class_name PlayerFunctions

@onready var main: String = ""

func _ready():
	main = str(get_parent().get_path())

func get_ply_from_id(id: int) -> Node:
	if !main: return null
	var ply: Node = get_node_or_null( main + "/Players/ply_" + str(id) )
	return ply

func get_char_from_id(id: int) -> Node:
	if !main: return null
	var character: Node = get_node_or_null( main + "/Players/char_" + str(id) )
	return character
	# TODO: make characters not depend on their name (so they can have their player swapped etc)

func get_chars_in_sphere(origin: Vector3, radius: float) -> Array:
	var space_state = get_world_3d().direct_space_state

	var shape = SphereShape3D.new()
	shape.radius = radius

	var query = PhysicsShapeQueryParameters3D.new()
	query.shape = shape
	query.transform = Transform3D(Basis(), origin)
	query.collide_with_areas = true
	query.collide_with_bodies = true
	query.collision_mask = 1  # adjust if needed
	query.exclude = [self]

	var results = space_state.intersect_shape(query, 32)

	var chars_in_radius := []
	for result in results:
		var node = result.get("collider", null)
		if node and node.is_in_group("characters"):
			chars_in_radius.append(node)

	return chars_in_radius
