class_name MenuNavigateCommand extends Command

@export var target_menu: State.UserInterfaces

func action(args: Array = []) -> void:
    var menu_layer: MenuLayer = Group.first("menu_layer")
    if args.is_empty():
        await menu_layer.navigate_to(target_menu)
    else:
        await menu_layer.navigate_to(target_menu, args[0])