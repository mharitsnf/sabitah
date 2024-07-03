class_name IslandGallery extends BaseMenu

@export_group("References")
@export var add_picture_button: GenericButton
@export var pictures_container: GridContainer
@export var island_name_label: Label

func _ready() -> void:
	super()
	assert(add_picture_button)
	assert(pictures_container)
	assert(island_name_label)

func set_data(new_data: Dictionary) -> void:
	if !new_data.is_empty():
		assert(new_data.has("sundial_manager"))

		data = new_data
		add_picture_button.args = [
			{
				'geotag_id': (data["sundial_manager"] as LocalSundialManager).get_island_tag_data()['id']
			}
		]
		island_name_label.text = (data["sundial_manager"] as LocalSundialManager).get_island_name()

func _mount_picture_buttons() -> void:
	var tag_dict: Dictionary = (data["sundial_manager"] as LocalSundialManager).get_island_tag_data()
	var filter_data: FilterData = PictureState.get_filter_data(tag_dict['id'])
	var pics: Array[PictureData] = PictureState.get_filtered_pictures([filter_data])
	for pd: PictureData in pics:
		pictures_container.add_child.call_deferred(pd.get_picture_button())

func _unmount_picture_buttons() -> void:
	for picture_button: Node in pictures_container.get_children():
		pictures_container.remove_child.call_deferred(picture_button)

func about_to_exit() -> void:
	await super()
	_unmount_picture_buttons()

# Overridden
func after_entering() -> void:
	_mount_picture_buttons()
	await super()
	if pictures_container.get_child_count() > 0:
		(pictures_container.get_child(0) as PictureButton).grab_focus()
	else:
		add_picture_button.grab_focus()