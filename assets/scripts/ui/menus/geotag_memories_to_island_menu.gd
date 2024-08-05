class_name GeotagMemoriesToIslandMenu extends BaseMenu

@export var confirm_button: GenericButton
@export var toggle_buttons_container: GridContainer

func set_data(new_data: Dictionary) -> void:
	if !new_data.is_empty():
		assert(new_data.has('geotag_id'))
		data = new_data
		confirm_button.args = [data['geotag_id']]

func _mount_toggle_buttons() -> void:
	# Find filters with geotag_id other than the current island
	var filters: Array[Dictionary] = GeotagState.all_filters.filter(
		func(fd: Dictionary) -> bool:
			return fd['geotag_id'] != data['geotag_id']
	)

	# Find pictures of that geotag id
	var mds: Array[MemoryData] = []
	for filter: Dictionary in filters:
		mds += MemoryState.get_memories({ 'geotag_id': filter['geotag_id'] })

	# Add picture buttons
	for md: MemoryData in mds:
		var tog: GenericToggleButton = md.get_toggle_button()
		toggle_buttons_container.add_child.call_deferred(tog)

func _unmount_toggle_buttons() -> void:
	for tog: Node in toggle_buttons_container.get_children():
		toggle_buttons_container.remove_child.call_deferred(tog)

func about_to_exit() -> void:
	await super()
	_unmount_toggle_buttons()

# Overridden
func after_entering() -> void:
	_mount_toggle_buttons()
	await super()
	if toggle_buttons_container.get_child_count() > 0:
		(toggle_buttons_container.get_child(0) as GenericToggleButton).grab_focus()