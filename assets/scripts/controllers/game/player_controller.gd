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

	(menu_layer as MenuLayer).menu_entered.connect(_on_menu_entered)
	(menu_layer as MenuLayer).menu_exited.connect(_on_menu_exited)

	(main_camera as MainCamera).follow_target_changed.connect(_on_follow_target_changed)

	_add_input_prompts()

func _on_menu_entered(_data: MenuLayer.MenuData) -> void:
	pass

func _on_menu_exited(_data: MenuLayer.MenuData) -> void:
	pass

func _on_follow_target_changed(new_vc: VirtualCamera) -> void:
	if (State.actor_im as ActorInputManager).get_current_controller() != self: return
	if input_prompts.is_empty(): return
	if new_vc is FirstPersonCamera:
		(input_prompts['RMB'] as InputPrompt).active = true
		hud_layer.add_input_prompt((input_prompts['RMB'] as InputPrompt))
	else:
		(input_prompts['RMB'] as InputPrompt).active = false
		hud_layer.remove_input_prompt((input_prompts['RMB'] as InputPrompt))

## Runs when the controller is entered.
func enter_controller() -> void:
	pass

func _add_input_prompts() -> void:
	var ip_factory: Common.InputPromptFactory = Common.InputPromptFactory.new()
	ip_factory.set_data("RMB", "Take picture")
	input_prompts['RMB'] = ip_factory.get_instance()

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