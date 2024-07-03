class_name  GameData extends RefCounted

var _key: State.LevelType
var _level: Node
var _world: World3D

func _init(__key: State.LevelType) -> void:
    _key = __key

func get_key() -> State.LevelType:
    return _key

func get_level() -> Node:
    return _level

func set_level(__level: Node3D) -> void:
    _level = __level
    _world = __level.get_world_3d()

func get_world() -> World3D:
    return _world