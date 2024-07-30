class_name MemoriesMenu extends BaseMenu

@export var menu_header_label: Label
@export var menu_button_container: GridContainer

func set_data(new_data: Dictionary) -> void:
	if !new_data.is_empty():
		assert(new_data.has('category_id'))

		data = new_data
		var memory_categories: Array[MemoryCategoryData] = MemoryState.get_memory_categories({ "id": data['category_id'] })
		assert((memory_categories as Array).size() > 0)
		data['memory_category_data'] = memory_categories[0]

		menu_header_label.text = (data['memory_category_data'] as MemoryCategoryData).get_memory_category().title

func _mount_menu_buttons() -> void:
	var incomplete_memories: Array[MemoryData] = MemoryState.get_memories({
		"category_id": data['category_id'],
		"locked_status": Memory.LockedStatus.UNLOCKED
	})

	for md: MemoryData in incomplete_memories:
		var menu_button: GenericButton = md.get_menu_button()
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