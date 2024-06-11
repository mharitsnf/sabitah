extends MeshInstance3D

func _process(_delta: float) -> void:
    var new_quat: Quaternion = Common.Geometry.recalculate_quaternion(basis, global_position.normalized())
    quaternion = new_quat