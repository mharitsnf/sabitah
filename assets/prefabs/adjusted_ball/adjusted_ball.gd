extends MeshInstance3D

func _process(_delta: float) -> void:
    var new_basis: Basis = Common.Geometry.adjust_basis_to_normal(basis, global_position.normalized())
    basis = new_basis