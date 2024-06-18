class_name TimeManager extends Node

@export var time_elapsed_speed: float = 1.
var time_elapsed: float = 0.

func _process(delta: float) -> void:
    time_elapsed += delta * time_elapsed_speed
    time_elapsed = fmod(time_elapsed, State.SECONDS_PER_DAY)

## Transforms the [elapsed_time] to rotation degrees.
func get_time_to_degrees() -> float:
    return remap(time_elapsed, 0., State.SECONDS_PER_DAY, 0., 360.)