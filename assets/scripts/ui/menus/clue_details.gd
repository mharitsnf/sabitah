class_name ClueDetails extends BaseMenu

@export var pictures_container: GridContainer
@export var menu_header: Label
@export var status_label: Label
@export var description_label: Label

func _ready() -> void:
	super()
	assert(menu_header)
	assert(status_label)
	assert(description_label)

func set_data(new_data: Dictionary) -> void:
	if !new_data.is_empty():
		assert(new_data.has('clue'))

		data = new_data
		menu_header.text = (data['clue'] as Clue).title
		status_label.text = ClueState.ClueStatus.keys()[(data['clue'] as Clue).status]
		description_label.text = (data['clue'] as Clue).description

func _mount_picture_buttons() -> void:
	var clue_pics: Array[PictureData] = PictureState.get_clue_pictures((data['clue'] as Clue).id)
	for pd: PictureData in clue_pics:
		pictures_container.add_child.call_deferred(pd.get_picture_button())

func _unmount_picture_buttons() -> void:
	for n: Node in pictures_container.get_children():
		pictures_container.remove_child.call_deferred(n)

func about_to_exit() -> void:
	await super()
	_unmount_picture_buttons()

# Overridden
func after_entering() -> void:
	_mount_picture_buttons()
	await super()
	
	if pictures_container.get_child_count() > 0:
		(pictures_container.get_child(0) as PictureButton).grab_focus()