class_name SetClueToConfirmCommand extends Command

func action(args: Array = []) -> void:
	assert(args.size() == 1)
	var clue: Clue = args[0]
	ClueState.clue_data_to_confirm = ClueState.get_clue_data_from_id(clue.id)
	var menu_layer: MenuLayer = Group.first("menu_layer")
	(menu_layer as MenuLayer).clear()