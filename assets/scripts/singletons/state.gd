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

## The scale of radiuses and gravity strength from main level to nav level.
const MAIN_TO_NAV_SCALE: float = .05
## The scale of radiuses and gravity strength from main level to globe level.
const MAIN_TO_GLOBE_SCALE: float = .05

## The position of the meridian in world space.
const PRIME_MERIDIAN: Vector3 = Vector3.RIGHT
const NORTH: Vector3 = Vector3.UP

const PICTURE_FOLDER_PATH: String = "res://assets/resources/pictures/"
const PICTURE_UNCATEGORIZED_FOLDER: String = "uncategorized/"

# Enums

enum LevelType {
	MAIN, NAV, GLOBE, NONE
}

enum UserInterfaces {
	NONE, MAIN_MENU, ISLAND_GALLERY, GALLERY, FULL_PICTURE, DELETE_PICTURE, GEOTAG_PICTURE
}

func get_island_lat_long_name(lat: float, long: float) -> String:
	return str(lat) + "°N, " + str(long) + "°S Island"

# region Picture

var picture_button_pscn: PackedScene = preload("res://assets/prefabs/user_interfaces/buttons/picture_button.tscn")
var picture_cache: Array[PictureData] = []

func get_geotag_name(id: String) -> String:
	var tags: Array[Dictionary] = get_geotags()

	var td: Array[Dictionary] = tags.filter(
		func(data: Dictionary) -> bool:
			return data["id"] == id
	)

	if td.is_empty(): return ""
	return (td[0] as Dictionary)['name']

func get_geotags() -> Array[Dictionary]:
	var tags: Array[Dictionary] = [{
		"id": "none",
		"name": "Uncategorized"
	}]

	for lsm: Node in Group.all("local_sundial_managers"):
		if !(lsm is LocalSundialManager): continue
		tags.append((lsm as LocalSundialManager).get_island_tag_data())

	return tags

func get_available_geotags() -> Array[Dictionary]:
	var available_tags: Array[Dictionary] = [{
		"id": "none",
		"name": "Uncategorized"
	}]

	for lsm: Node in Group.all("local_sundial_managers"):
		if !(lsm is LocalSundialManager): continue
		if !(lsm as LocalSundialManager).first_marker_done: continue
		available_tags.append((lsm as LocalSundialManager).get_island_tag_data())

	return available_tags

## Load pictures from the pictures folder and create cache of it.
func load_pictures() -> void:
	var dir: DirAccess = DirAccess.open(State.PICTURE_FOLDER_PATH)
	if !dir:
		push_error("Cannot load files!") 
		return

	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	while file_name != "":
		if !dir.current_is_dir():
			create_picture_cache(State.PICTURE_FOLDER_PATH + file_name)
		file_name = dir.get_next()

func create_picture_cache(resource_path: String) -> void:
	# see if we have this resource inside the cache already.
	var existing_picture: Array[PictureData] = picture_cache.filter(
		func(_pd: PictureData) -> bool:
			return _pd.get_picture().resource_path == resource_path
	)
	
	# if we have the picture resource inside the cache, return
	if !existing_picture.is_empty():
		return

	# create a new button and picture
	var pic: Resource = load(resource_path)
	var pic_button: PictureButton = picture_button_pscn.instantiate()
	(pic_button as PictureButton).assigned_picture = pic

	# add to cache
	picture_cache.append(PictureData.new(pic, pic_button))

## Remove a specific picture from the cache.
func remove_picture_cache(picture: Picture) -> void:
	var existing_picture: Array[PictureData] = picture_cache.filter(
		func(_pd: PictureData) -> bool:
			return _pd.get_picture().resource_path == picture.resource_path
	)
	
	# No file found in cache, returning
	if existing_picture.is_empty():
		return

	# Remove from cache and delete the picture button (if any)
	var existing_pd: PictureData = existing_picture[0]
	if existing_pd.get_picture_button():
		existing_pd.get_picture_button().queue_free()
	picture_cache.erase(existing_pd)

## Look for Picture files that have been deleted inside [picture_cache], and then remove them from the cache.
func remove_invalid_caches() -> void:
	var to_be_erased: Array[PictureData] = []
	
	for pd: PictureData in picture_cache:
		var exists: bool = FileAccess.file_exists(pd.get_picture().resource_path)
		if !exists: to_be_erased.append(pd)
	
	for epd: PictureData in to_be_erased:
		if epd.get_picture_button(): epd.get_picture_button().queue_free()
		picture_cache.erase(epd)

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

var input_prompt_pscn: PackedScene = preload("res://assets/prefabs/hud/input_prompt/input_prompt.tscn")

# region local sundial data

var local_sundial: LocalSundialManager
var local_sundial_data: Dictionary = {

}

# region References

## Reference to the game scene's ActorInputManager.
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

func _ready() -> void:
	load_pictures()
