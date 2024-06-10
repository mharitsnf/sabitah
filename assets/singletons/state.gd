extends Node

class Game extends RefCounted:
    enum GameType {
        MAIN, MINI
    }

    static var scale_dict: Dictionary = {
        GameType.MAIN: 1.,
        GameType.MINI: .05
    }

    const PLANET_RADIUS : float = 1485.6
    const GRAVITY_RADIUS_SCALE: float = 2.

    static func get_planet_data(type: GameType) -> Dictionary:
        return {
            "radius": PLANET_RADIUS * scale_dict[type]
        }

    static func get_gravity_data(type: GameType) -> Dictionary:
        return {
            "radius": PLANET_RADIUS * GRAVITY_RADIUS_SCALE * scale_dict[type],
            "strength": ProjectSettings.get_setting("physics/3d/default_gravity") * scale_dict[type]
        }

        

var has_given_mayor_gift: bool = false