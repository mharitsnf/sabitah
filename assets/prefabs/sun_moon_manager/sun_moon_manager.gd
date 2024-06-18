class_name SunMoonManager extends Node3D

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