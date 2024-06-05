class_name MenuNavigateCommand extends Command

@export var target_menu: MenuLayer.Menus

func action(_args: Array = []) -> Common.Promise:
    var menu_layer: MenuLayer = Group.first("menu_layer")
    return await menu_layer.navigate_to(target_menu)