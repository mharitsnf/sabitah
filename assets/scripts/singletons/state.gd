## Singleton class for storing global game variables.
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
const STAR_RADIUS_SCALE: float = 3.7

## The scale of radiuses and gravity strength from main level to nav level.
const MAIN_TO_NAV_SCALE: float = .05
## The scale of radiuses and gravity strength from main level to globe level.
const MAIN_TO_GLOBE_SCALE: float = .05

## The position of the meridian in world space.
const PRIME_MERIDIAN: Vector3 = Vector3.RIGHT
const NORTH: Vector3 = Vector3.UP

const SUNSET_ANGLE: float = -.3

func _ready() -> void:
	tree = get_tree()

# Enums

enum StarType {
	MAIN, BACKGROUND
}

enum LevelType {
	MAIN, NAV, GLOBE, NONE
}

enum UserInterfaces {
	NONE, MAIN_MENU, ISLAND_GALLERY, GALLERY, FULL_PICTURE, DELETE_PICTURE, GEOTAG_PICTURE, FILTER_GALLERY, GEOTAG_TO_ISLAND,
	CLUES_MENU, CLUE_DETAILS, COLLECTIBLES_MENU, COLLECTIBLE_DETAILS
}

# region Game data
var world_dict: Dictionary = {
	LevelType.MAIN: GameData.new(LevelType.MAIN),
	LevelType.NAV: GameData.new(LevelType.NAV),
	LevelType.GLOBE: GameData.new(LevelType.GLOBE)
}

# region Input prompts

var input_prompt_pscn: PackedScene = preload("res://assets/prefabs/hud/input_prompt/input_prompt.tscn")

# region local sundial data

var waypoint_markers: Array[WaypointMarker]
var local_sundials: Array[LocalSundialManager]

var local_sundial: LocalSundialManager
var node_sundial: LocalSundialManager
var local_sundial_data: Dictionary = {}

var inside_island_areas: Dictionary = {}

signal teleport_to_node_sundial

func get_island_lat_long_name(lat: float, long: float) -> String:
	return str(lat) + "°N, " + str(long) + "°S Island"

func has_node_sundial() -> bool:
	return node_sundial != null
	
# region References

## Reference to the game scene's ActorInputManager.
var tree: SceneTree

var actor_im: ActorInputManager
var globe_im: GlobeInputManager

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
		"sun_moon_distance": State.PLANET_RADIUS * applied_scale * SUN_MOON_RADIUS_SCALE,
		"star_distance": State.PLANET_RADIUS * applied_scale * STAR_RADIUS_SCALE
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
