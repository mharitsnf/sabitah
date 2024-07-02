class_name DeletePictureCommand extends Command

func action(args: Array = []) -> void:
	assert(args.size() == 1)

	# erase
	var pic: Picture = args[0]
	DirAccess.remove_absolute(pic.resource_path)

	var menu_layer: MenuLayer = Group.first("menu_layer")
	(menu_layer as MenuLayer).remove_last_menu()
	await (menu_layer as MenuLayer).back()