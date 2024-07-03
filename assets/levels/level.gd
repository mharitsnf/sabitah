class_name GameLevel extends Node3D

@export var level_type: State.LevelType

func _ready() -> void:
	PictureState.update_all_filters()

func _enter_tree() -> void:
	if !State.get_level(level_type):
		State.set_level(level_type, self)

	if is_node_ready():
		PictureState.update_all_filters()