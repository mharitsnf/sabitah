class_name CharacterVisuals extends Node3D

@export var animation_tree: AnimationTree

var animation_state: String = "Grounded"

func set_animation_parameter(param: String, value: Variant) -> void:
	animation_tree.set(param, value)
