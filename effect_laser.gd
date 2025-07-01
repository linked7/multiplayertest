extends RayCast3D

@onready var beam_mesh = $BeamMesh
var end: Vector3

func _process(_delta: float) -> void:
	force_raycast_update()

	if is_colliding():
		end = to_local(get_collision_point())
	else:
		end = to_local(global_transform.origin + target_position)

	var distance = position.distance_to(end)
	
	# Assuming BeamMesh is a CylinderMesh or similar
	if beam_mesh.mesh is CylinderMesh:
		var mesh = beam_mesh.mesh
		mesh.height = distance
		beam_mesh.mesh = mesh  # Re-assign to apply changes

	# Position the beam midway and point it in the right direction
	beam_mesh.transform.origin = position.lerp(end, 0.5)
	#beam_mesh.look_at(end, Vector3.UP)
