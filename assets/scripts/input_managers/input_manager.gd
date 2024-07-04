class_name InputManager extends Node

var data_dict: Dictionary = {}

var previous_data: PlayerData
var current_data: PlayerData

var transitioning: bool = false

signal current_data_changed

var menu_layer: MenuLayer

func _ready() -> void:
	_setup_references()
	_create_player_data()
	_set_existing_instances()

## Private. Setup references for the input manager
func _setup_references() -> void:
	menu_layer = Group.first("menu_layer")
	assert(menu_layer)

## Private. Create player data based on the packed scenes dictionary
func _create_player_data() -> void:
	pass

## Private. Create instances of player data.
func _set_existing_instances() -> void:
	pass

func get_current_instance() -> Node:
	if !current_data: return null
	return current_data.get_instance()

## Private. Check if input is allowed.
func _input_allowed() -> bool:
	if !current_data: 
		return false
	if !current_data.get_instance(): 
		return false
	if menu_layer.has_active_menu(): 
		return false
	return true

## Switch current_data to a new one [_new_data].
func switch_data(_new_data: PlayerData) -> Array:
	return [false]