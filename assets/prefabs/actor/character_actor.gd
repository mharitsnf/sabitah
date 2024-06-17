class_name CharacterActor extends BaseActor

@export var move_speed: float = 1.

# region Horizontal Movement
# =====

func _move(ref_basis: Basis, xz_vector: Vector2) -> void:
	ref_basis = ref_basis.orthonormalized()
	var dir: Vector3 = -ref_basis.z * xz_vector.y + ref_basis.x * xz_vector.x
	dir = dir.normalized()
	apply_central_force(dir * move_speed)