class_name MenuNavigateCommand extends Command

@export var target_menu: State.UserInterfaces

func action(args: Array = []) -> void:
	var menu_layer: MenuLayer = Group.first("menu_layer")
	
	if args.is_empty():
		await menu_layer.navigate_to(target_menu)
	else:
		var menu_navigate_data: Dictionary = args[0]
		await menu_layer.navigate_to(target_menu, menu_navigate_data)
