class_name PlayerController extends Node

var input_prompts: Array = []

var hud_layer: HUDLayer

func _ready() -> void:
	hud_layer = Group.first("hud_layer")
	assert(hud_layer)

## Runs when the controller is entered.
func enter_controller() -> void:
	pass

func delegated_process(_delta: float) -> void:
	pass

func player_input_process(_delta: float) -> void:
	pass

func player_unhandled_input(_event: InputEvent) -> void:
	pass

## Runs when the controller is exited.
func exit_controller() -> void:
	pass