class_name CluesMenu extends BaseMenu

@export_group("References")
@export var active_clues_container: GridContainer
@export var completed_clues_container: GridContainer
@export var completed_category: VBoxContainer

func _ready() -> void:
	super()
	assert(active_clues_container)
	assert(completed_clues_container)

func set_data(new_data: Dictionary) -> void:
	if !new_data.is_empty():
		assert(new_data.has('is_confirmation'))

		data = new_data
		completed_category.visible = !data['is_confirmation']

func _mount_clues_menu_buttons() -> void:
	if !data['is_confirmation']:
		for cd: ClueData in ClueState.get_clues_by_status(ClueState.ClueStatus.ACTIVE):
			var clue_menu_button: GenericButton = cd.get_clue_menu_button()
			(clue_menu_button.args[0] as Dictionary).is_confirmation = false
			active_clues_container.add_child.call_deferred(clue_menu_button)
		
		for cd: ClueData in ClueState.get_clues_by_status(ClueState.ClueStatus.COMPLETED):
			var clue_menu_button: GenericButton = cd.get_clue_menu_button()
			(clue_menu_button.args[0] as Dictionary).is_confirmation = false
			completed_clues_container.add_child.call_deferred(clue_menu_button)

	else:
		for cd: ClueData in ClueState.get_clues_by_status(ClueState.ClueStatus.ACTIVE):
			var clue_menu_button: GenericButton = cd.get_clue_menu_button()
			(clue_menu_button.args[0] as Dictionary).is_confirmation = true
			active_clues_container.add_child.call_deferred(clue_menu_button)

func _unmount_clues_menu_buttons() -> void:
	for n: Node in active_clues_container.get_children():
		active_clues_container.remove_child.call_deferred(n)
	for n: Node in completed_clues_container.get_children():
		completed_clues_container.remove_child.call_deferred(n)

func about_to_exit() -> void:
	await super()
	_unmount_clues_menu_buttons()

# Overridden
func after_entering() -> void:
	_mount_clues_menu_buttons()
	await super()
	
	if active_clues_container.get_child_count() > 0:
		(active_clues_container.get_child(0) as GenericButton).grab_focus()
		return
	if completed_clues_container.get_child_count() > 0:
		(completed_clues_container.get_child(0) as GenericButton).grab_focus()
		return