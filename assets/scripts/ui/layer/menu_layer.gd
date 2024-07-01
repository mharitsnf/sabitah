class_name MenuLayer extends CanvasLayer

# region Menu data
class MenuData extends RefCounted:
	var _key: State.UserInterfaces
	var _pscn: PackedScene
	var _instance: BaseMenu

	func _init(__pscn: PackedScene, __key: State.UserInterfaces) -> void:
		_pscn = __pscn
		_key = __key
	
	func get_key() -> State.UserInterfaces:
		return _key

	func create_instance() -> void:
		_instance = _pscn.instantiate()

	func get_instance() -> BaseMenu:
		return _instance

@export var menu_pscns: Dictionary = {
	State.UserInterfaces.MAIN_MENU: null,
	State.UserInterfaces.ISLAND_GALLERY: null,
}

var menu_data_dict: Dictionary = {}

# History stack
var history_stack: Array[MenuData] = []

# Flags
var transitioning: bool = false
var switching: bool = false
var toggle_main_menu_allowed: bool = true

signal menu_entered(data: MenuData)
signal menu_exited(data: MenuData)

# region Lifecycle functions

func _ready() -> void:
	_create_menu_data()

func _unhandled_input(event: InputEvent) -> void:
	if switching: return
	if has_active_menu(): return
	if !toggle_main_menu_allowed: return
	if event.is_action_pressed("toggle_main_menu"):
		navigate_to(State.UserInterfaces.MAIN_MENU)

# region User interface navigation functions

## Helper function for adding an instance to the menu layer.
func _instance_enter(data: MenuData) -> void:
	add_child.call_deferred(data.get_instance())
	await data.get_instance().tree_entered

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
func navigate_to(ui: State.UserInterfaces, menu_data: Dictionary = {}) -> void:
	if !_is_navigating_allowed(): return

	switching = true

	var next_data: MenuData = menu_data_dict[ui]
	if !next_data.get_instance(): next_data.create_instance()
	await (next_data.get_instance() as BaseMenu).set_data(menu_data)

	# If we have an active menu, remove it from the stack first.
	if !history_stack.is_empty():
		var current_data: MenuData = history_stack.back()
		await _instance_exit((current_data as MenuData))

	# Add the new menu to the stack.
	history_stack.push_back(next_data)
	await _instance_enter(next_data)

	switching = false

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

# region Helper functions

# Initialization

## Private. Function to create menu datas on ready.
func _create_menu_data() -> void:
	for k: State.UserInterfaces in menu_pscns.keys():
		if !menu_pscns[k] is PackedScene: continue
		menu_data_dict[k] = MenuData.new(menu_pscns[k], k)
