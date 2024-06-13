class_name BaseProjection extends StaticBody3D

var reference_node: Node3D
var normal_target: Node3D
var world_type: State.Game.GameType

func _process(_delta: float) -> void:
	_project_rotation()
	_project_position()

## Private. Project the position of the [reference_node] to this node.
func _project_position() -> void:
	if reference_node:
		var unit_pos: Vector3 = reference_node.global_position.normalized()
		var ref_flat_y: float = (reference_node.basis.inverse() * reference_node.global_position).y
		var mini_scale: float = State.Game.get_scale(State.Game.GameType.MINI)
		ref_flat_y = (ref_flat_y * mini_scale) if world_type == State.Game.GameType.MINI else (ref_flat_y * (1./mini_scale))
		global_position = unit_pos * ref_flat_y

## Private. Project the rotation of the [reference_node] to this node.
func _project_rotation() -> void:
	if reference_node:
		quaternion = reference_node.basis.get_rotation_quaternion()

		if reference_node is BaseActor and normal_target:
			var quat: Quaternion = reference_node.normal_target.basis.get_rotation_quaternion()
			normal_target.quaternion = quat