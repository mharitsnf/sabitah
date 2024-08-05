class_name GeotagPicturesToIslandMenu extends BaseMenu

@export var confirm_button: GenericButton
@export var pictures_container: GridContainer

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
	var pics: Array[PictureData] = []
	for filter: Dictionary in filters:
		pics += PictureState.get_pictures({ 'geotag_id': filter['geotag_id'] })

	# Add picture buttons
	for p: PictureData in pics:
		var tog: PictureToggleButton = p.get_picture_toggle_button()
		pictures_container.add_child.call_deferred(tog)

func _unmount_toggle_buttons() -> void:
	for tog: Node in pictures_container.get_children():
		pictures_container.remove_child.call_deferred(tog)

func about_to_exit() -> void:
	await super()
	_unmount_toggle_buttons()

# Overridden
func after_entering() -> void:
	_mount_toggle_buttons()
	await super()
	if pictures_container.get_child_count() > 0:
		(pictures_container.get_child(0) as PictureToggleButton).grab_focus()
