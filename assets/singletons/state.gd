extends Node

class Game extends RefCounted:
    class GameData extends RefCounted:
        var _key: GameType
        var _level: Node
        var _world: World3D
        var _scale: float
        func _init(__key: GameType, __scale: float) -> void:
            _key = __key
            _scale = __scale
        func get_key() -> GameType:
            return _key
        func get_level() -> Node:
            return _level
        func set_level(__level: Node3D) -> void:
            _level = __level
            _world = __level.get_world_3d()
        func get_world() -> World3D:
            return _world
        func get_scale() -> float:
            return _scale

    enum GameType {
        MAIN, MINI, NONE
    }

    static var world_dict: Dictionary = {
        GameType.MAIN: GameData.new(GameType.MAIN, 1.),
        GameType.MINI: GameData.new(GameType.MINI, .05),
    }

    const PLANET_RADIUS : float = 1485.6
    const GRAVITY_RADIUS_SCALE: float = 2.

    static func get_scale(type: GameType) -> float:
        return (world_dict[type] as GameData).get_scale()

    ## Returns the level node of the provided [type].
    static func get_level(type: GameType) -> Node:
        return (world_dict[type] as GameData).get_level()

    ## Returns the [GameType] of the provided [world].
    static func get_world_type(world: World3D) -> GameType:
        for wd: GameData in world_dict.values():
            if wd.get_world() == world: return wd.get_key()
        return GameType.NONE

    ## Returns planetary data (e.g., radius).
    static func get_planet_data(type: GameType) -> Dictionary:
        return {
            "radius": PLANET_RADIUS * (world_dict[type] as GameData).get_scale()
        }

    ## Returns gravitational data (e.g., radius, gravity strength).
    static func get_gravity_data(type: GameType) -> Dictionary:
        return {
            "radius": PLANET_RADIUS * GRAVITY_RADIUS_SCALE * (world_dict[type] as GameData).get_scale(),
            "strength": ProjectSettings.get_setting("physics/3d/default_gravity") * (world_dict[type] as GameData).get_scale()
        }

var has_given_mayor_gift: bool = false