class_name MenuNavigateCommand extends Command

@export var target_menu: State.UserInterfaces

func action(_args: Array = []) -> void:
    var menu_layer: MenuLayer = Group.first("menu_layer")
    await menu_layer.navigate_to(target_menu)