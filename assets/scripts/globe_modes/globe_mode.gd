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

	(menu_layer as MenuLayer).menu_back.connect(_on_menu_back)
	(menu_layer as MenuLayer).menu_navigate_to.connect(_on_menu_navigate_to)

func enter_mode() -> void:
	await Common.wait(.1)

func delegated_physics_process(_delta: float) -> void:
	pass

func delegated_process(_delta: float) -> void:
	pass	

func player_input_process(_delta: float) -> void:
	pass

func delegated_unhandled_input(_event: InputEvent) -> void:
	pass

func _on_menu_back(_old: MenuLayer.MenuData, _new: MenuLayer.MenuData) -> void:
	print("asdf1")

func _on_menu_navigate_to(_old: MenuLayer.MenuData, _new: MenuLayer.MenuData) -> void:
	print("asdf2")

func exit_mode() -> void:
	await Common.wait(.1)