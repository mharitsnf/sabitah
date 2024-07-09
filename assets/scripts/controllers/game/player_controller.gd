class_name PlayerController extends Node

var input_prompts: Array = []

var hud_layer: HUDLayer
var menu_layer: MenuLayer

func _ready() -> void:
	hud_layer = Group.first("hud_layer")
	menu_layer = Group.first("menu_layer")

	assert(hud_layer)
	assert(menu_layer)

	(menu_layer as MenuLayer).menu_entered.connect(_on_menu_entered)
	(menu_layer as MenuLayer).menu_exited.connect(_on_menu_exited)

func _on_menu_entered(_data: MenuLayer.MenuData) -> void:
	pass

func _on_menu_exited(_data: MenuLayer.MenuData) -> void:
	pass

## Runs when the controller is entered.
func enter_controller() -> void:
	pass

func delegated_process(_delta: float) -> void:
	pass

func player_input_process(_delta: float) -> void:
	pass

func player_unhandled_input(_event: InputEvent) -> void:
	pass

func _reset_inputs() -> void:
	pass

## Runs when the controller is exited.
func exit_controller() -> void:
	pass