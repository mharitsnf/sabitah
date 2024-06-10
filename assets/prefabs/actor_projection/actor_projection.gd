class_name ActorProjection extends StaticBody3D

## The target world type in which this node will exist.
var target_world_type: State.Game.GameType
## The reference to the target world.
var target_world: Node
## A reference to the original, projected node.
var reference_node: Node3D

## The [Node3D] in which the normal will be adjusted according to the ocean's normal.
@onready var normal_target: Node3D = %CollisionShape3D

func _process(_delta: float) -> void:
	_project_position()
	_project_rotation()

## Adds this node to the target world.
func add_to_world() -> void:
	if !is_inside_tree():
		target_world.add_child.call_deferred(self)

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
