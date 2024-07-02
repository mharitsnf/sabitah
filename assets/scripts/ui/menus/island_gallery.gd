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
		data = new_data
		island_name_label.text = (data["sundial_manager"] as LocalSundialManager).get_island_name()

func _mount_picture_buttons() -> void:
	for pd: PictureData in State.picture_cache:
		pictures_container.add_child.call_deferred(pd.get_picture_button())

func _unmount_picture_buttons() -> void:
	for pd: PictureData in State.picture_cache:
		pictures_container.remove_child.call_deferred(pd.get_picture_button())

func about_to_exit() -> void:
	_unmount_picture_buttons()
	await super()

# Overridden
func after_entering() -> void:
	_mount_picture_buttons()
	await super()
	add_picture_button.grab_focus()