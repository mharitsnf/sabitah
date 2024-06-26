class_name IslandRegistration extends LatLongSearch

@export_group("Switch scene commands")
@export_subgroup("Canceling")
@export var before_cancel_cmd: Command
@export var after_cancel_cmd: Command

## Margin of error for the player.
const ISLAND_REGISTRATION_MARGIN_OF_ERROR: float = 1000.

func enter_mode() -> void:
	menu_layer.toggle_main_menu_allowed = false
	hud_layer.show_instruction_panel()

	print(State.local_sundial_data)

func player_input_process(_delta: float) -> void:
	_get_cancel_input()
	_get_confirm_island_location_input()

func _get_confirm_island_location_input() -> void:
	if Input.is_action_just_pressed("confirm_island_location"):
		var query_latlong: Array = Common.Geometry.point_to_latlng(query_res['normal'])
		var dist: float = Common.Geometry.haversine_dist(
			State.local_sundial_data['lat'],
			State.local_sundial_data['long'],
			query_latlong[0],
			query_latlong[1],
			State.PLANET_RADIUS
		)
		
		print(dist)
		if dist < ISLAND_REGISTRATION_MARGIN_OF_ERROR:
			State.local_sundial.first_marker_done = true
			print("correct")
		else:
			print("incorrect")

func _get_cancel_input() -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		State.local_sundial_data = {}

		var scene_manager: SceneManager = Group.first("scene_manager")
		(scene_manager as SceneManager).switch_scene(
			SceneManager.Scenes.GAME,
			before_cancel_cmd, 
			after_cancel_cmd
		)

func exit_mode() -> void:
	menu_layer.toggle_main_menu_allowed = true
	await hud_layer.hide_instruction_panel()
