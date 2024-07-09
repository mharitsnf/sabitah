class_name SetClueToConfirmCommand extends Command

func action(args: Array = []) -> void:
	assert(args.size() == 1)
	var clue: Clue = args[0]
	ClueState.clue_id_to_confirm = clue.id
	var menu_layer: MenuLayer = Group.first("menu_layer")
	(menu_layer as MenuLayer).clear()