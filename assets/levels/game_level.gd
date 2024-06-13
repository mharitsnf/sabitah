class_name GameLevel extends Node3D

@export var game_level_type: State.Game.GameType

func _enter_tree() -> void:
    State.Game.set_level(game_level_type, self)