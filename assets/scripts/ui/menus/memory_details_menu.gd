class_name MemoryDetailsMenu extends BaseMenu

@export var menu_header_label: Label
@export var menu_button_container: VBoxContainer
@export var owner_label: Label

func set_data(new_data: Dictionary) -> void:
	if !new_data.is_empty():
		assert(new_data.has('memory_id'))

		data = new_data
		var memories: Array[MemoryData] = MemoryState.get_memories({ "id": data['memory_id'] })
		assert((memories as Array).size() > 0)
		data['memory_data'] = memories[0]

		menu_header_label.text = (data['memory_data'] as MemoryData).get_memory().title
		owner_label.text = (data['memory_data'] as MemoryData).get_memory().memory_owner.name

func _mount_menu_buttons() -> void:
	var mental_images: Array[MentalImageData] = MemoryState.get_mental_images({
		"memory_id": data['memory_id'],
	})

	for mid: MentalImageData in mental_images:
		var menu_button: GenericButton = mid.get_menu_button()
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