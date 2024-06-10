class_name GameLevel extends Node3D

@export var game_level_type: State.Game.GameType

func _ready() -> void:
    (State.Game.world_dict[game_level_type] as State.Game.GameData).set_world(get_world_3d())
    print((State.Game.world_dict[game_level_type] as State.Game.GameData).get_world())