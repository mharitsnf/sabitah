class_name MenuNavigateCommand extends Command

@export var target_menu: MenuLayer.Menus

func action(_args: Array = []) -> void:
    var menu_layer: MenuLayer = Group.first("menu_layer")
    menu_layer.navigate_to(target_menu)