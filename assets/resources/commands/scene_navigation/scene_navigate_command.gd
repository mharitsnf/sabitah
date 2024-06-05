class_name SceneNavigateCommand extends Command

@export var target_scene: SceneManager.Scenes

func action(_args: Array = []) -> Common.Promise:
    var scene_manager: SceneManager = Group.first("scene_manager")
    var menu_layer: MenuLayer = Group.first("menu_layer")
    await (menu_layer as MenuLayer).clear()
    scene_manager.switch_scene(target_scene)
    return Common.Promise.new()