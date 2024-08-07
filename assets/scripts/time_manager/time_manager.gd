class_name TimeManager extends Node

@export var time_elapsed_speed: float = 1.
var time_elapsed: float = 79200.

var scene_manager: SceneManager

func _ready() -> void:
	scene_manager = Group.first("scene_manager")
	assert(scene_manager)

func _process(delta: float) -> void:
	if scene_manager.get_active_scene_type() == SceneManager.Scenes.GAME:
		time_elapsed += delta * time_elapsed_speed
		time_elapsed = fmod(time_elapsed, State.SECONDS_PER_DAY)

## Transforms the [elapsed_time] to rotation degrees.
func get_degrees() -> float:
	return remap(time_elapsed, 0., State.SECONDS_PER_DAY, 360., 0.)

func _snap_to_five(value: int) -> int:
	return floor(value / 5.) * 5

func get_game_time() -> Array:
	var seconds: int = _snap_to_five(floori(fmod(time_elapsed, 60.)))
	var minutes: int = _snap_to_five(floori(fmod(time_elapsed / 60., 60.)))
	var hours: int = floori(fmod(time_elapsed / 3600., 60.))

	var str_seconds: String = "0"+str(seconds) if seconds < 10 else str(seconds)
	var str_minutes: String = "0"+str(minutes) if minutes < 10 else str(minutes)
	var str_hours: String = "0"+str(hours) if hours < 10 else str(hours)
	return [
		str_hours, str_minutes, str_seconds, 
		hours, minutes, seconds
	]