class_name IslandMemoriesMenu extends BaseMenu

@export var island_name_label: Label
@export var add_memories_button: GenericButton
@export var menu_button_container: VBoxContainer

func set_data(new_data: Dictionary) -> void:
	if !new_data.is_empty():
		assert(new_data.has("geotag_id"))
		assert(new_data.has("geotag_name"))

		data = new_data
		add_memories_button.args = [
			{
				'geotag_id': data['geotag_id']
			}
		]
		island_name_label.text = data['geotag_name']

func _mount_menu_buttons() -> void:
	var memories: Array[MemoryData] = MemoryState.get_memories({ 'geotag_id': data['geotag_id'] })
	for md: MemoryData in memories:
		var menu_button: GenericButton = md.get_menu_button()
		menu_button_container.add_child.call_deferred(menu_button)

func _unmount_menu_buttons() -> void:
	for menu_button: Node in menu_button_container.get_children():
		menu_button_container.remove_child.call_deferred(menu_button)

func about_to_exit() -> void:
	await super()
	_unmount_menu_buttons()

# Overridden
func after_entering() -> void:
	_mount_menu_buttons()
	await super()
	if menu_button_container.get_child_count() > 0:
		(menu_button_container.get_child(0) as GenericButton).grab_focus()
	else:
		add_memories_button.grab_focus()