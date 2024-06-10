extends Node

class Game extends RefCounted:
    const PLANET_RADIUS : float = 1485.6
    const MINI_PLANET_SCALE: float = .01

    func get_mini_planet_scale() -> float:
        return MINI_PLANET_SCALE

    static func get_mini_planet_radius() -> float:
        return PLANET_RADIUS * MINI_PLANET_SCALE

var has_given_mayor_gift: bool = false