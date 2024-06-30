class_name MenuLayer extends CanvasLayer

# region Menu data
class MenuData extends RefCounted:
	var _pscn: PackedScene
	var _instance: BaseMenu

	func _init(__pscn: PackedScene) -> void:
		_pscn = __pscn
	
	func create_instance() -> void:
		_instance = _pscn.instantiate()

	func get_instance() -> BaseMenu:
		return _instance

@export var menu_pscns: Dictionary = {
	State.UserInterfaces.MAIN_MENU: null,
	State.UserInterfaces.ISLAND_MENU: null,
}

var menu_data_dict: Dictionary = {}

# History stack
var history_stack: Array[MenuData] = []

# Flags
var transitioning: bool = false
var toggle_main_menu_allowed: bool = true

# region Lifecycle functions

func _ready() -> void:
	_create_menu_data()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_main_menu") and toggle_main_menu_allowed:
		if history_stack.is_empty(): navigate_to(State.UserInterfaces.MAIN_MENU)
		else: clear()

# region User interface navigation functions

## Helper function for adding an instance to the menu layer.
func _instance_enter(instance: BaseMenu) -> void:
	add_child.call_deferred(instance)
	await instance.tree_entered

	transitioning = true
	await instance.after_entering()
	transitioning = false

## Helper function for removing an instance from the menu layer.
func _instance_exit(instance: BaseMenu) -> void:
	transitioning = true
	await instance.about_to_exit()
	transitioning = false
	
	remove_child.call_deferred(instance)
	await instance.tree_exited

## Helper function for checking if navigation is allowed.
func _is_navigating_allowed() -> bool:
	if transitioning:
		push_warning("Menu Layer is still transitioning")
		return false
	return true

## Returns true if the menu layer has an active menu.
func has_active_menu() -> bool:
	return !history_stack.is_empty()

## Function for navigating to the previous menu.
func back() -> void:
	if !_is_navigating_allowed(): return

	if !history_stack.is_empty():
		var current_data: MenuData = history_stack.pop_back()
		await _instance_exit((current_data as MenuData).get_instance())

	if !history_stack.is_empty():
		var prev_data: MenuData = history_stack.back()
		_instance_enter((prev_data as MenuData).get_instance())

## Function for navigating to another menu.
func navigate_to(ui: State.UserInterfaces) -> void:
	if !_is_navigating_allowed(): return
	
	var next_data: MenuData = menu_data_dict[ui]
	if !next_data.get_instance(): next_data.create_instance()

	# If we have an active menu, remove it from the stack first.
	if !history_stack.is_empty():
		var current_data: MenuData = history_stack.back()
		await _instance_exit((current_data as MenuData).get_instance())

	# Add the new menu to the stack.
	history_stack.push_back(next_data)
	_instance_enter(next_data.get_instance())

## Function for clearing the history stack (remove all active menus)
func clear() -> void:
	if !_is_navigating_allowed(): return

	# If the history stack is not empty, remove the current instance from the tree
	# and clear the history stack.
	if !history_stack.is_empty():
		var current_data: MenuData = history_stack.back()
		await _instance_exit((current_data as MenuData).get_instance())
	
		history_stack = []

# region Helper functions

# Initialization

## Private. Function to create menu datas on ready.
func _create_menu_data() -> void:
	for k: State.UserInterfaces in menu_pscns.keys():
		if !menu_pscns[k] is PackedScene: continue
		menu_data_dict[k] = MenuData.new(menu_pscns[k])
