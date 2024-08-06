extends Node

var parent: Node3D

func _ready() -> void:
	parent = get_parent()
	assert(parent)
	assert(parent is Node3D)

func _process(_delta: float) -> void:
	parent.quaternion = Common.Geometry.recalculate_quaternion(parent.global_basis, parent.global_position.normalized())