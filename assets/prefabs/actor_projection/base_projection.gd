class_name BaseProjection extends StaticBody3D

var reference_node: Node3D
var normal_target: Node3D
var world_type: State.Game.GameType

func _process(_delta: float) -> void:
	_project_position()
	_project_rotation()

## Private. Project the position of the [reference_node] to this node.
func _project_position() -> void:
	if reference_node:
		var unit_pos: Vector3 = reference_node.global_position.normalized()
		var target_planet_data: Dictionary = State.Game.get_planet_data(world_type)
		global_position = unit_pos * target_planet_data['radius']

## Private. Project the rotation of the [reference_node] to this node.
func _project_rotation() -> void:
	if reference_node:
		basis = reference_node.basis

		if reference_node is BaseActor and normal_target:
			var quat: Quaternion = Quaternion(reference_node.normal_target.basis)
			normal_target.quaternion = quat