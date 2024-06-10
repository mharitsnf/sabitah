extends Node

class Game extends RefCounted:
    class GameData extends RefCounted:
        var _key: GameType
        var _world: World3D
        var _scale: float
        func _init(__key: GameType, __scale: float) -> void:
            _key = __key
            _scale = __scale
        func set_world(value: World3D) -> void:
            _world = value
        func get_world() -> World3D:
            return _world
        func get_scale() -> float:
            return _scale

    enum GameType {
        MAIN, MINI
    }

    static var world_dict: Dictionary = {
        GameType.MAIN: GameData.new(GameType.MAIN, 1.),
        GameType.MINI: GameData.new(GameType.MINI, .05),
    }

    const PLANET_RADIUS : float = 1485.6
    const GRAVITY_RADIUS_SCALE: float = 2.

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