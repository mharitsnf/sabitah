class_name SceneNavigateCommand extends Command

@export var target_scene: SceneManager.Scenes

func action(_args: Array = []) -> void:
    var scene_manager: SceneManager = Group.first("scene_manager")
    scene_manager.switch_scene(target_scene)