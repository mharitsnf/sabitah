class_name GlobeMode extends Node

@export_group("Switch scene commands")
@export_subgroup("Canceling")
@export var before_cancel_cmd: Command
@export var after_cancel_cmd: Command

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
	await Common.wait(.1)

func delegated_physics_process(_delta: float) -> void:
	pass

func delegated_process(_delta: float) -> void:
	pass	

func player_input_process(_delta: float) -> void:
	pass

func delegated_unhandled_input(event: InputEvent) -> void:
	if menu_layer.switching: return
	if transitioning: return
	if event.is_action_pressed("ui_cancel"):
		_exit_globe_scene()

func _exit_globe_scene() -> void:
	var scene_manager: SceneManager = Group.first("scene_manager")
	await (scene_manager as SceneManager).switch_scene(
		SceneManager.Scenes.GAME,
		before_cancel_cmd, 
		after_cancel_cmd
	)

func _on_menu_entered(_data: MenuLayer.MenuData) -> void:
	pass

func _on_menu_exited(_data: MenuLayer.MenuData) -> void:
	pass

func exit_mode() -> void:
	await Common.wait(.1)