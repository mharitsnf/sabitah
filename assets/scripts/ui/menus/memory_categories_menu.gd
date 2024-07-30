class_name MemoryCategoriesMenu extends BaseMenu

@export var menu_button_container: GridContainer

func _mount_menu_buttons() -> void:
	for mcd: MemoryCategoryData in MemoryState.memory_categories_cache:
		# Make sure the memory cateogy has an unlocked memory first.
		var unlocked_memories: Array[MemoryData] = MemoryState.get_memories({ "category_id": mcd.get_memory_category().id, "locked_status": Memory.LockedStatus.UNLOCKED })
		if unlocked_memories.size() == 0: continue

		var menu_button: GenericButton = mcd.get_menu_button()
		menu_button_container.add_child.call_deferred(menu_button)

func _unmount_menu_buttons() -> void:
	for c: Node in menu_button_container.get_children():
		menu_button_container.remove_child.call_deferred(c)

func about_to_exit() -> void:
	await super()
	_unmount_menu_buttons()

# Overridden
func after_entering() -> void:
	_mount_menu_buttons()
	await super()

	if menu_button_container.get_child_count() > 0:
		(menu_button_container.get_child(0) as GenericButton).grab_focus()
		return
