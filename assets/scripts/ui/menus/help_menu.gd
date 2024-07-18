class_name HelpMenu extends BaseMenu

@export var buttons_container: GridContainer

func _mount_help_menu_buttons() -> void:
	var help: Array[HelpData] = HelpState.get_helps({ "visibility": HelpState.HelpCategoryVisibility.VISIBLE })
	for hd: HelpData in help:
		if hd.get_page_count() == 0: continue
		var menu_button: GenericButton = hd.get_menu_button()
		buttons_container.add_child.call_deferred(menu_button)

func _unmount_help_menu_buttons() -> void:
	for c: Node in buttons_container.get_children():
		buttons_container.remove_child.call_deferred(c)

func about_to_exit() -> void:
	await super()
	_unmount_help_menu_buttons()

# Overridden
func after_entering() -> void:
	_mount_help_menu_buttons()
	await super()

	if buttons_container.get_child_count() > 0:
		(buttons_container.get_child(0) as GenericButton).grab_focus()