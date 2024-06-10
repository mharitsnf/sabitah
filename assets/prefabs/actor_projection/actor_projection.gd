class_name ActorProjection extends StaticBody3D

var target_world_type: State.Game.GameType
var target_world: Node
var reference_node: Node3D

func _process(_delta: float) -> void:
	_project_position()
	_project_rotation()

func add_to_world() -> void:
	if !is_inside_tree():
		target_world.add_child.call_deferred(self)

func _project_position() -> void:
	if reference_node:
		var unit_pos: Vector3 = reference_node.global_position.normalized()

		var target_planet_data: Dictionary = State.Game.get_planet_data(target_world_type)
		global_position = unit_pos * target_planet_data['radius']

func _project_rotation() -> void:
	if reference_node:
		basis = reference_node.basis
