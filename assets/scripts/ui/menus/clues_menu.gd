class_name CluesMenu extends BaseMenu

@export_group("References")
@export var active_clues_container: GridContainer
@export var completed_clues_container: GridContainer

func _ready() -> void:
	super()
	assert(active_clues_container)
	assert(completed_clues_container)

func _mount_clues_menu_buttons() -> void:
	for cd: ClueData in ClueState.clue_cache:
		var clue: Clue = cd.get_clue()
		match clue.status:
			ClueState.ClueStatus.COMPLETED: completed_clues_container.add_child.call_deferred(cd.get_clue_menu_button())
			_: active_clues_container.add_child.call_deferred(cd.get_clue_menu_button())

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