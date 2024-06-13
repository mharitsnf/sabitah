extends Node

class Game extends RefCounted:
    class GameData extends RefCounted:
        var _key: GameType
        var _level: Node
        var _world: World3D
        func _init(__key: GameType) -> void:
            _key = __key
        func get_key() -> GameType:
            return _key
        func get_level() -> Node:
            return _level
        func set_level(__level: Node3D) -> void:
            _level = __level
            _world = __level.get_world_3d()
        func get_world() -> World3D:
            return _world

    enum GameType {
        MAIN, NAV, NONE
    }

    static var world_dict: Dictionary = {
        GameType.MAIN: GameData.new(GameType.MAIN),
        GameType.NAV: GameData.new(GameType.NAV),
    }

    const PLANET_RADIUS : float = 1485.6
    const GRAVITY_RADIUS_SCALE: float = 2.
    const MAIN_TO_NAV_SCALE: float = .05

    static func set_level(type: GameType, level: Node) -> void:
        (world_dict[type] as GameData).set_level(level)

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
        var applied_scale: float = (1.) if type == GameType.MAIN else MAIN_TO_NAV_SCALE
        return {
            "radius": PLANET_RADIUS * applied_scale
        }

    ## Returns gravitational data (e.g., radius, gravity strength).
    static func get_gravity_data(type: GameType) -> Dictionary:
        var applied_scale: float = (1.) if type == GameType.MAIN else MAIN_TO_NAV_SCALE
        return {
            "radius": PLANET_RADIUS * GRAVITY_RADIUS_SCALE * applied_scale,
            "strength": ProjectSettings.get_setting("physics/3d/default_gravity") * applied_scale
        }

var has_given_mayor_gift: bool = false