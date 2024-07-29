class_name MenuLayer extends CanvasLayer

@export var menu_pscns: Dictionary = {}

var menu_data_dict: Dictionary = {}

# History stack
var history_stack: Array[MenuData] = []

# Flags
var transitioning: bool = false
var switching: bool = false
var toggle_main_menu_allowed: bool = true

signal menu_entered(data: MenuData)
signal menu_exited(data: MenuData)
signal menu_cleared

# region Lifecycle functions

func _ready() -> void:
	_create_menu_data()

func _unhandled_input(event: InputEvent) -> void:
	if switching: return
	if has_active_menu(): return
	if !toggle_main_menu_allowed: return
	if event.is_action_pressed("toggle_main_menu"):
		navigate_to(State.MENU_MAIN_MENU)

# region User interface navigation functions

## Helper function for adding an instance to the menu layer.
func _instance_enter(data: MenuData, info_data: Dictionary = {}) -> void:
	add_child.call_deferred(data.get_instance())
	await data.get_instance().tree_entered

	await data.get_instance().set_data(info_data)

	transitioning = true
	await data.get_instance().after_entering()
	transitioning = false
	menu_entered.emit(data)

## Helper function for removing an instance from the menu layer.
func _instance_exit(data: MenuData) -> void:
	transitioning = true
	await data.get_instance().about_to_exit()
	transitioning = false
	
	remove_child.call_deferred(data.get_instance())
	await data.get_instance().tree_exited
	menu_exited.emit(data)

## Helper function for checking if navigation is allowed.
func _is_navigating_allowed() -> bool:
	if transitioning:
		push_warning("Menu Layer is still transitioning")
		return false
	return true

## Returns true if the menu layer has an active menu.
func has_active_menu() -> bool:
	return !history_stack.is_empty() or switching

## Function for navigating to the previous menu.
func back() -> void:
	if !_is_navigating_allowed(): return

	switching = true

	if !history_stack.is_empty():
		var current_data: MenuData = history_stack.pop_back()
		await _instance_exit((current_data as MenuData))

	if !history_stack.is_empty():
		var prev_data: MenuData = history_stack.back()
		await _instance_enter((prev_data as MenuData))

	switching = false

## Function for navigating to another menu.
func navigate_to(ui: String, menu_data: Dictionary = {}) -> void:
	if !_is_navigating_allowed(): return

	switching = true

	var next_data: MenuData = menu_data_dict[ui]
	if !next_data.get_instance(): next_data.create_instance()

	# If we have an active menu, remove it from the stack first.
	if !history_stack.is_empty():
		var current_data: MenuData = history_stack.back()
		await _instance_exit((current_data as MenuData))

	# Add the new menu to the stack.
	history_stack.push_back(next_data)
	await _instance_enter(next_data, menu_data)

	switching = false

func remove_last_menu() -> void:
	if !(history_stack.size() > 2):
		push_error("History stack size is less than 3!")
		return
	history_stack.remove_at(history_stack.size() - 2)

## Function for clearing the history stack (remove all active menus)
func clear() -> void:
	if !_is_navigating_allowed(): return

	switching = true

	# If the history stack is not empty, remove the current instance from the tree
	# and clear the history stack.
	if !history_stack.is_empty():
		var current_data: MenuData = history_stack.back()
		await _instance_exit((current_data as MenuData))
	
		history_stack = []

	switching = false
	menu_cleared.emit()

# region Helper functions

# Initialization

## Private. Function to create menu datas on ready.
func _create_menu_data() -> void:
	for k: String in menu_pscns.keys():
		if !menu_pscns[k] is PackedScene: continue
		menu_data_dict[k] = MenuData.new(menu_pscns[k], k)
