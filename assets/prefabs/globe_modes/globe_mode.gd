class_name GlobeMode extends Node

var menu_layer: MenuLayer
var hud_layer: GlobeHUDLayer
var main_camera: MainCamera

func _ready() -> void:
	menu_layer = Group.first("menu_layer")
	hud_layer = Group.first("hud_layer")
	main_camera = Group.first("main_camera")

	assert(menu_layer)
	assert(hud_layer)
	assert(main_camera)

func enter_mode() -> void:
	await get_tree().create_timer(.1).timeout

func delegated_physics_process(_delta: float) -> void:
	pass

func delegated_process(_delta: float) -> void:
	pass	

func player_input_process(_delta: float) -> void:
	pass

func delegated_unhandled_input(_event: InputEvent) -> void:
	pass

func exit_mode() -> void:
	await get_tree().create_timer(.1).timeout