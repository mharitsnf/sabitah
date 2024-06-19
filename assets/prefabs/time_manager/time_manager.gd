class_name TimeManager extends Node

@export var time_elapsed_speed: float = 1.
var time_elapsed: float = 0.

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
    return remap(time_elapsed, 0., State.SECONDS_PER_DAY, 0., 360.)