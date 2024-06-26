class_name SceneNavigateCommand extends Command

@export var target_scene: SceneManager.Scenes
@export var before_switch_command: Command
@export var after_switch_command: Command

func action(_args: Array = []) -> void:
	var scene_manager: SceneManager = Group.first("scene_manager")
	var menu_layer: MenuLayer = Group.first("menu_layer")
	await (menu_layer as MenuLayer).clear()
	await scene_manager.switch_scene(target_scene, before_switch_command, after_switch_command)