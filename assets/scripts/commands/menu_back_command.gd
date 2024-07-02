class_name MenuBackCommand extends Command

func action(_args: Array = []) -> void:
	var menu_layer: MenuLayer = Group.first("menu_layer")
	await (menu_layer as MenuLayer).back()