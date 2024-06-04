class_name MenuLayer extends CanvasLayer

enum Menus {
    NONE, MAIN_MENU
}

var menu_dict: Dictionary = {
    Menus.MAIN_MENU: preload("res://assets/prefabs/menu_layer/main_menu.tscn")
}

var menu_instances: Dictionary = {
    Menus.MAIN_MENU: null
}

class UIData extends RefCounted:
    var _key: Menus
    var _instance: BaseMenu

    func _init(__key: Menus, __instance: BaseMenu) -> void:
        _key = __key
        _instance = __instance
    
    func get_instance() -> BaseMenu:
        return _instance

var transitioning: bool = false
var history_stack: Array[UIData] = []

func _process(_delta: float) -> void:
    if Input.is_action_just_pressed("toggle_main_menu"):
        if history_stack.is_empty(): navigate_to(Menus.MAIN_MENU)
        else: clear()

## Helper function for adding an instance to the menu layer.
func _instance_enter(instance: BaseMenu) -> void:
    add_child(instance)
    transitioning = true
    await instance.after_entering()
    transitioning = false

## Helper function for removing an instance from the menu layer.
func _instance_exit(instance: BaseMenu) -> void:
    transitioning = true
    await instance.about_to_exit()
    transitioning = false
    remove_child(instance)

## Helper function for checking if navigation is allowed.
func _is_navigating_allowed() -> bool:
    if transitioning:
        push_warning("Menu Layer is still transitioning")
        return false
    return true

func has_active_menu() -> bool:
    return !history_stack.is_empty()

## Function for navigating to the previous menu.
func back() -> void:
    if !_is_navigating_allowed(): return

    if !history_stack.is_empty():
        var current_data: UIData = history_stack.pop_back()
        var current_instance: BaseMenu = (current_data as UIData).get_instance()
        _instance_exit(current_instance)

    if !history_stack.is_empty():
        var prev_data: UIData = history_stack.back()
        var prev_instance: BaseMenu = (prev_data as UIData).get_instance()
        _instance_enter(prev_instance)

## Function for navigating to another menu.
func navigate_to(menu: Menus) -> void:
    if !_is_navigating_allowed(): return
    
    if !menu_instances[menu]: menu_instances[menu] = menu_dict[menu].instantiate()
    var instance: BaseMenu = menu_instances[menu]

    var new_data: UIData = UIData.new(menu, instance)

    # If we have an active menu, remove it from the stack first.
    if !history_stack.is_empty():
        var current_data: UIData = history_stack.back()
        var current_instance: BaseMenu = (current_data as UIData).get_instance()
        _instance_exit(current_instance)

    # Add the new menu to the stack.
    history_stack.push_back(new_data)
    _instance_enter(instance)

## Function for clearing the history stack (remove all active menus)
func clear() -> void:
    if !_is_navigating_allowed(): return

    # If the history stack is not empty, remove the current instance from the tree
    # and clear the history stack.
    if !history_stack.is_empty():
        var current_data: UIData = history_stack.back()
        var current_instance: BaseMenu = (current_data as UIData).get_instance()
        _instance_exit(current_instance)
    
        history_stack = []