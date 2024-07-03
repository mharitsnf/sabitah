class_name GeotagToIsland extends BaseMenu

@export var confirm_button: GenericButton
@export var pictures_container: GridContainer

func set_data(new_data: Dictionary) -> void:
	assert(new_data.has('geotag_id'))
	data = new_data
	confirm_button.args = [data['geotag_id']]

func _mount_pictures_toggle_button() -> void:
	var filters: Array[FilterData] = PictureState.all_filters.filter(
		func(fd: FilterData) -> bool:
			return fd.get_geotag_id() != data['geotag_id']
	)
	var pics: Array[PictureData] = PictureState.get_filtered_pictures(filters)
	for p: PictureData in pics:
		var tog: PictureToggleButton = p.get_picture_toggle_button()
		pictures_container.add_child.call_deferred(tog)

func _unmount_pictures_toggle_button() -> void:
	for tog: Node in pictures_container.get_children():
		pictures_container.remove_child.call_deferred(tog)

func about_to_exit() -> void:
	await super()
	_unmount_pictures_toggle_button()

# Overridden
func after_entering() -> void:
	_mount_pictures_toggle_button()
	await super()
	if pictures_container.get_child_count() > 0:
		(pictures_container.get_child(0) as PictureToggleButton).grab_focus()
