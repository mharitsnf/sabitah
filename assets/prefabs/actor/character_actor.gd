class_name CharacterActor extends BaseActor

@export_group("Horizontal movement")
@export var move_speed: float = 1.
@export_group("Rotation")
@export var rotation_weight: float = 1.
@export_group("References")
@export var visual_node: Node3D

# region Horizontal Movement
# =====

func _move(ref_basis: Basis, xz_vector: Vector2) -> void:
	var dir: Vector3 = -ref_basis.z * xz_vector.y + ref_basis.x * xz_vector.x
	dir = dir.normalized()
	apply_central_force(dir * move_speed)

## Private. Rotate the mesh based on the direction of movement.
func _rotate_visuals(ref_basis: Basis, xz_vector: Vector2) -> void:
	if !visual_node: return
	if xz_vector == Vector2.ZERO: return

	ref_basis = ref_basis.orthonormalized()
	var dir: Vector3 = (-ref_basis.z * xz_vector.y + ref_basis.x * xz_vector.x).normalized()
	dir = basis.inverse() * dir
	dir = Vector3(dir.x, 0., dir.z).normalized()

	var new_quat: Quaternion = Basis.looking_at(dir, visual_node.basis.y).get_rotation_quaternion()
	visual_node.quaternion = visual_node.basis.get_rotation_quaternion().slerp(new_quat, get_process_delta_time() * rotation_weight)