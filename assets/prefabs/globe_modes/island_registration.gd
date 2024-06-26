class_name IslandRegistration extends LatLongSearch

@export_group("Switch scene commands")
@export_subgroup("Canceling")
@export var before_cancel_cmd: Command
@export var after_cancel_cmd: Command

func enter_mode() -> void:
	menu_layer.toggle_main_menu_allowed = false
	hud_layer.show_instruction_panel()

func player_input_process(_delta: float) -> void:
	_get_cancel_input()
	_get_confirm_island_location_input()

func _get_confirm_island_location_input() -> void:
	if Input.is_action_just_pressed("confirm_island_location"):
		print("Show correct / incorrect result")

func _get_cancel_input() -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		var scene_manager: SceneManager = Group.first("scene_manager")
		(scene_manager as SceneManager).switch_scene(
			SceneManager.Scenes.GAME,
			before_cancel_cmd, 
			after_cancel_cmd
		)

func exit_mode() -> void:
	menu_layer.toggle_main_menu_allowed = true
	await hud_layer.hide_instruction_panel()
