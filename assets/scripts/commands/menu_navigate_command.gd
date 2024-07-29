class_name MenuNavigateCommand extends Command

@export var custom_args: Dictionary
@export var target_menu: String

func action(args: Array = []) -> void:
	var menu_layer: MenuLayer = Group.first("menu_layer")
	
	if args.is_empty():
		await menu_layer.navigate_to(target_menu, custom_args)
	else:
		assert(args[0] is Dictionary)
		var menu_navigate_data: Dictionary = args[0]
		menu_navigate_data.merge(custom_args, true)
		await menu_layer.navigate_to(target_menu, menu_navigate_data)
