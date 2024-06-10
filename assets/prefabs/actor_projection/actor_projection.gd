class_name ActorProjection extends StaticBody3D

## The target world type in which this node will exist.
var target_world_type: State.Game.GameType
## The reference to the target world.
var target_world: Node
## A reference to the original, projected node.
var reference_node: Node3D:
	set(value):
		reference_node = value
		if reference_node:
			var ref_world_type: State.Game.GameType = State.Game.get_world_type(reference_node.get_world_3d())
			target_world_type = State.Game.GameType.MINI if ref_world_type == State.Game.GameType.MAIN else State.Game.GameType.MAIN

## The [Node3D] in which the normal will be adjusted according to the ocean's normal.
@onready var normal_target: Node3D = %CollisionShape3D

func _process(_delta: float) -> void:
	_project_position()
	_project_rotation()

## Adds this node to the target world.
func add_to_world() -> void:
	if !reference_node:
		push_error("Reference node is not set yet.")
		return
	if is_inside_tree():
		push_error("Node is already inside tree.")
		return

	State.Game.get_level(target_world_type).add_child.call_deferred(self)

## Private. Project the position of the [reference_node] to this node.
func _project_position() -> void:
	if reference_node:
		var unit_pos: Vector3 = reference_node.global_position.normalized()

		var target_planet_data: Dictionary = State.Game.get_planet_data(target_world_type)
		global_position = unit_pos * target_planet_data['radius']

## Private. Project the rotation of the [reference_node] to this node.
func _project_rotation() -> void:
	if reference_node:
		basis = reference_node.basis

		if reference_node is BaseActor and normal_target:
			normal_target.basis = reference_node.normal_target.basis
