class_name GlobeMode extends PlayerController

@export_group("Switch scene commands")
@export_subgroup("Canceling")
@export var before_cancel_cmd: Command
@export var after_cancel_cmd: Command

var transitioning: bool = false

func bool_unhandled_input(event: InputEvent) -> bool:
	if menu_layer.switching: return false
	if transitioning: return false
	if event.is_action_pressed("ui_cancel"):
		_exit_globe_scene()
		return false
	return true

func _exit_globe_scene() -> void:
	var scene_manager: SceneManager = Group.first("scene_manager")
	await (scene_manager as SceneManager).switch_scene(
		SceneManager.Scenes.GAME,
		before_cancel_cmd, 
		after_cancel_cmd
	)