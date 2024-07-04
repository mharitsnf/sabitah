class_name SunMoonManager extends Node3D

@export var level_type: State.LevelType
@export_group("Position")
@export var sun_initial_position: Vector3 = Vector3.RIGHT
@export var moon_initial_position: Vector3 = Vector3.LEFT
@export_group("References")
@export var sun: SunMoonLight
@export var moon: SunMoonLight

var time_manager: TimeManager

func _ready() -> void:
	time_manager = Group.first("time_manager")

	assert(time_manager)
	assert(sun)
	assert(moon)

	_setup_sun_moon_position()

func _setup_sun_moon_position() -> void:
	var pd: Dictionary = State.get_planet_data(level_type)
	sun.position = sun_initial_position * pd['sun_moon_distance']
	moon.position = moon_initial_position * pd['sun_moon_distance']

func _process(_delta: float) -> void:
	_rotate_sun_moon()

func _rotate_sun_moon() -> void:
	rotation_degrees.y = (time_manager.get_degrees() + 180.)