class_name GlobeMode extends Node

@export_group("Switch scene commands")
@export_subgroup("Canceling")
@export var before_cancel_cmd: Command
@export var after_cancel_cmd: Command

var input_prompts: Array[InputPrompt]

var menu_layer: MenuLayer
var hud_layer: GlobeHUDLayer
var main_camera: MainCamera

var transitioning: bool = false

func _ready() -> void:
	menu_layer = Group.first("menu_layer")
	hud_layer = Group.first("hud_layer")
	main_camera = Group.first("main_camera")

	assert(menu_layer)
	assert(hud_layer)
	assert(main_camera)

	(menu_layer as MenuLayer).menu_entered.connect(_on_menu_entered)
	(menu_layer as MenuLayer).menu_exited.connect(_on_menu_exited)

func enter_mode() -> void:
	if false: await Common.wait(.1)

func delegated_physics_process(_delta: float) -> void:
	pass

func delegated_process(_delta: float) -> void:
	pass	

func player_input_process(_delta: float) -> void:
	pass

func delegated_unhandled_input(event: InputEvent) -> bool:
	if menu_layer.switching: return false
	if transitioning: return false
	if event.is_action_pressed("ui_cancel"):
		_exit_globe_scene()
		return false
	return true

func _exit_globe_scene() -> void:
	var scene_manager: SceneManager = Group.first("scene_manager")
	await (scene_manager as SceneManager).switch_scene(
		SceneManager.Scenes.GAME,
		before_cancel_cmd, 
		after_cancel_cmd
	)

func _is_input_prompt_active(idx: int) -> bool:
	assert(input_prompts.size() > 0)
	return (input_prompts[idx] as InputPrompt).active

func _show_input_prompt(idx: int) -> void:
	assert(input_prompts.size() > 0)
	(input_prompts[idx] as InputPrompt).active = true
	hud_layer.add_input_prompt((input_prompts[idx] as InputPrompt))

func _hide_input_prompt(idx: int) -> void:
	assert(input_prompts.size() > 0)
	(input_prompts[idx] as InputPrompt).active = false
	hud_layer.remove_input_prompt((input_prompts[idx] as InputPrompt))

func _on_menu_entered(_data: MenuData) -> void:
	pass

func _on_menu_exited(_data: MenuData) -> void:
	pass

func exit_mode() -> void:
	if false: await Common.wait(.1)