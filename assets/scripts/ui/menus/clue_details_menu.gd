class_name ClueDetailsMenu extends BaseMenu

@export var set_active_button: Button
@export var set_completed_button: Button
@export var confirm_button: GenericButton
@export var pictures_container: GridContainer
@export var confirm_button_container: HBoxContainer
@export var menu_header: Label
@export var status_label: Label
@export var description_label: Label

func _ready() -> void:
	super()
	assert(confirm_button)
	assert(pictures_container)
	assert(confirm_button_container)
	assert(menu_header)
	assert(status_label)
	assert(description_label)

	set_active_button.pressed.connect(_on_set_status_button_pressed.bind(set_active_button))
	set_completed_button.pressed.connect(_on_set_status_button_pressed.bind(set_completed_button))

func set_data(new_data: Dictionary) -> void:
	if !new_data.is_empty():
		assert(new_data.has('clue_id'))
		assert(new_data['clue_id'] is String)
		assert(new_data.has('is_confirmation'))

		data = new_data
		data['clue_data'] = ClueState.get_clue_data_by_id(data['clue_id'])
		data['clue'] = (data['clue_data'] as ClueData).get_clue()

		# set arguments
		confirm_button.args = [(data['clue'] as Clue)]

		menu_header.text = (data['clue'] as Clue).title
		status_label.text = ClueState.ClueStatus.keys()[(data['clue'] as Clue).status]
		description_label.text = (data['clue'] as Clue).description

		confirm_button_container.visible = new_data['is_confirmation'] as bool

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
		(pictures_container.get_child(0) as GenericButton).grab_focus()
		return
	else:
		set_active_button.grab_focus()

func _on_set_status_button_pressed(button: Button) -> void:
	if button.name == "Active":
		(data['clue_data'] as ClueData).set_clue_status(ClueState.ClueStatus.ACTIVE)
	elif button.name == "Completed":
		(data['clue_data'] as ClueData).set_clue_status(ClueState.ClueStatus.COMPLETED)

	status_label.text = ClueState.ClueStatus.keys()[(data['clue'] as Clue).status]
