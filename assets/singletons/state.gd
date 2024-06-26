extends Node

# region Constants

## The radius of the main planet.
const PLANET_RADIUS: float = 1485.6
## Amount of seconds in a day.
const SECONDS_PER_DAY: float = 86400.

## Multiply this with [State.PLANET_RADIUS] to find the radius of the gravity field.
const GRAVITY_RADIUS_SCALE: float = 2.
## Multiply this with [State.PLANET_RADIUS] to find the distance between origin and sun/moon position.
const SUN_MOON_RADIUS_SCALE: float = 3.

## The scale of radiuses and gravity strength from main level to nav level.
const MAIN_TO_NAV_SCALE: float = .05
## The scale of radiuses and gravity strength from main level to globe level.
const MAIN_TO_GLOBE_SCALE: float = .05

## The position of the meridian in world space.
const PRIME_MERIDIAN: Vector3 = Vector3.RIGHT
const NORTH: Vector3 = Vector3.UP

enum LevelType {
    MAIN, NAV, GLOBE, NONE
}

# region Game data

class GameData extends RefCounted:
    var _key: LevelType
    var _level: Node
    var _world: World3D
    func _init(__key: LevelType) -> void:
        _key = __key
    func get_key() -> LevelType:
        return _key
    func get_level() -> Node:
        return _level
    func set_level(__level: Node3D) -> void:
        _level = __level
        _world = __level.get_world_3d()
    func get_world() -> World3D:
        return _world

var world_dict: Dictionary = {
    LevelType.MAIN: GameData.new(LevelType.MAIN),
    LevelType.NAV: GameData.new(LevelType.NAV),
    LevelType.GLOBE: GameData.new(LevelType.GLOBE)
}

# region Packed scenes

var input_prompt_pscn: PackedScene = preload("res://assets/prefabs/ui_components/input_prompt.tscn")

# region local sundial data

var local_sundial_data: Dictionary = {

}

# region References

## Reference to the game scene's PlayerActorManager.
var game_pam: PlayerActorManager
var pgmm: PlayerGlobeModeManager

var game_camera: Camera3D
var globe_camera: Camera3D

var game_sun: DirectionalLight3D
var globe_sun: DirectionalLight3D

# region Setters and getters

func get_world_3d(type: LevelType) -> World3D:
    return (world_dict[type] as GameData).get_world()

func set_level(type: LevelType, level: Node) -> void:
    (world_dict[type] as GameData).set_level(level)

## Returns the level node of the provided [type].
func get_level(type: LevelType) -> Node:
    return (world_dict[type] as GameData).get_level()

## Returns the [LevelType] of the provided [world].
func get_world_type(world: World3D) -> LevelType:
    for wd: GameData in world_dict.values():
        if wd.get_world() == world: return wd.get_key()
    return LevelType.NONE

## Returns planetary data (e.g., radius).
func get_planet_data(type: LevelType) -> Dictionary:
    var applied_scale: float
    match type:
        LevelType.NAV: applied_scale = MAIN_TO_NAV_SCALE
        LevelType.GLOBE: applied_scale = MAIN_TO_GLOBE_SCALE
        _: applied_scale = 1.
    
    return {
        "radius": State.PLANET_RADIUS * applied_scale,
        "sun_moon_distance": State.PLANET_RADIUS * applied_scale * SUN_MOON_RADIUS_SCALE
    }

## Returns gravitational data (e.g., radius, gravity strength).
func get_gravity_data(type: LevelType) -> Dictionary:
    var applied_scale: float
    match type:
        LevelType.NAV: applied_scale = MAIN_TO_NAV_SCALE
        LevelType.GLOBE: applied_scale = MAIN_TO_GLOBE_SCALE
        _: applied_scale = 1.
    
    return {
        "radius": State.PLANET_RADIUS * GRAVITY_RADIUS_SCALE * applied_scale,
        "strength": ProjectSettings.get_setting("physics/3d/default_gravity") * applied_scale
    }

var has_given_mayor_gift: bool = false