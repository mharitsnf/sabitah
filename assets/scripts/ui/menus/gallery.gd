class_name Gallery extends BaseMenu

@export_group("References")
@export var filter_tag_container: GridContainer
@export var picture_button_container: GridContainer
@export var add_filter_button: GenericButton
@export var picture_button_pscn: PackedScene

func _ready() -> void:
	super()
	assert(filter_tag_container)
	assert(picture_button_container)
	assert(add_filter_button)
	assert(picture_button_pscn)

func _mount_picture_buttons() -> void:
	for pd: PictureData in PictureState.get_pictures_data(true):
		picture_button_container.add_child.call_deferred(pd.get_picture_button())

func _unmount_picture_buttons() -> void:
	for pic_button: Node in picture_button_container.get_children():
		picture_button_container.remove_child.call_deferred(pic_button)

func _mount_active_filter_labels() -> void:
	if PictureState.gallery_active_filters.is_empty():
		var tag_label: Label = _create_geotag_label("Show all")
		filter_tag_container.add_child.call_deferred(tag_label)
		return

	for pd: FilterData in PictureState.gallery_active_filters:
		var tag_name: String = PictureState.get_geotag_name(pd.get_geotag_id())
		var tag_label: Label = _create_geotag_label(tag_name)
		filter_tag_container.add_child.call_deferred(tag_label)

func _unmount_active_filter_labels() -> void:
	for label: Node in filter_tag_container.get_children():
		filter_tag_container.remove_child.call_deferred(label)

func _create_geotag_label(label_text: String) -> Label:
	var label: Label = Label.new()
	label.text = label_text
	return label

func about_to_exit() -> void:
	await super()
	_unmount_active_filter_labels()
	_unmount_picture_buttons()

# Overridden
func after_entering() -> void:
	await picture_button_container.tree_entered
	_mount_picture_buttons()
	_mount_active_filter_labels()
	await super()
	add_filter_button.grab_focus()