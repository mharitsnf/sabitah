class_name PlayerController extends Node

var input_prompts: Dictionary = {}
var hud_layer: HUDLayer
var menu_layer: MenuLayer
var main_camera: MainCamera

func _ready() -> void:
	hud_layer = Group.first("hud_layer")
	menu_layer = Group.first("menu_layer")
	main_camera = Group.first("main_camera")

	assert(hud_layer)
	assert(menu_layer)
	assert(main_camera)

	(State.actor_im as ActorInputManager).current_data_changed.connect(_on_current_data_changed)

	(menu_layer as MenuLayer).menu_entered.connect(_on_menu_entered)
	(menu_layer as MenuLayer).menu_exited.connect(_on_menu_exited)
	(main_camera as MainCamera).follow_target_changed.connect(_on_follow_target_changed)

	Common.dialogue_entered.connect(_on_dialogue_entered)

func _on_menu_entered(_data: MenuData) -> void:
	_reset_inputs()

func _on_menu_exited(_data: MenuData) -> void:
	pass

func _on_dialogue_entered() -> void:
	_reset_inputs()

func _on_follow_target_changed(_new_vc: VirtualCamera) -> void:
	pass

func _on_current_data_changed() -> void:
	if State.actor_im.get_current_controller() != self:
		_reset_inputs()

## Runs when the controller is entered.
func enter_controller() -> void:
	if false: await Common.wait(.1)

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
	if false: await Common.wait(.1)
