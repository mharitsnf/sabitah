class_name Gallery extends BaseMenu

@export_group("References")
@export var picture_button_container: GridContainer
@export var add_filter_button: GenericButton
@export var picture_button_pscn: PackedScene

var picture_cache: Array[PictureData] = []

func _ready() -> void:
	super()
	assert(picture_button_container)
	assert(add_filter_button)
	assert(picture_button_pscn)

func _mount_picture_buttons() -> void:
	for pd: PictureData in State.picture_cache:
		picture_button_container.add_child.call_deferred(pd.get_picture_button())

func _unmount_picture_buttons() -> void:
	for pd: PictureData in State.picture_cache:
		picture_button_container.remove_child.call_deferred(pd.get_picture_button())

func about_to_exit() -> void:
	await super()
	_unmount_picture_buttons()

# Overridden
func after_entering() -> void:
	await picture_button_container.tree_entered
	_mount_picture_buttons()
	await super()
	add_filter_button.grab_focus()