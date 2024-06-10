class_name GameLevel extends Node3D

@export var game_level_type: State.Game.GameType

func _enter_tree() -> void:
    (State.Game.world_dict[game_level_type] as State.Game.GameData).set_level(self)