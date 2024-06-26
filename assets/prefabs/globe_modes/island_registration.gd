class_name IslandRegistration extends LatLongSearch

@export_group("Switch scene commands")
@export_subgroup("Canceling")
@export var before_cancel_cmd: Command
@export var after_cancel_cmd: Command
@export_group("References")
@export var level_anim: AnimationPlayer
@export_subgroup("Packed scenes")
@export var first_marker_pscn: PackedScene

## Margin of error for the player.
const ISLAND_REGISTRATION_MARGIN_OF_ERROR: float = 500.

var transitioning: bool = false

func _ready() -> void:
	super()

	assert(level_anim)
	assert(first_marker_pscn)

func enter_mode() -> void:
	menu_layer.toggle_main_menu_allowed = false
	hud_layer.show_instruction_panel()

func player_input_process(_delta: float) -> void:
	print(transitioning)
	_get_cancel_input()
	_get_confirm_island_location_input()

func _get_confirm_island_location_input() -> void:
	if Input.is_action_just_pressed("confirm_island_location") and !transitioning:
		var query_latlong: Array = Common.Geometry.point_to_latlng(query_res['normal'])
		var dist: float = Common.Geometry.haversine_dist(
			State.local_sundial_data['lat'],
			State.local_sundial_data['long'],
			query_latlong[0],
			query_latlong[1],
			State.PLANET_RADIUS
		)
		
		if dist < ISLAND_REGISTRATION_MARGIN_OF_ERROR:
			transitioning = true
			State.local_sundial.first_marker_done = true
			level_anim.play("add_first_marker")
			await level_anim.animation_finished
			await _exit_globe_scene()
			transitioning = false

		else:
			transitioning = true
			await show_incorrect_message()
			transitioning = false

func show_correct_message() -> void:
	hud_layer.set_instruction_text(
		"Correct!",
		Common.Status.SUCCESS
	)

func show_incorrect_message() -> void:
	await hud_layer.set_instruction_text(
		"Wrong location, try again or exit with [ESC].",
		Common.Status.ERROR
	)

func add_first_marker() -> void:
	var marker: Node3D = first_marker_pscn.instantiate()
	var level: Node = State.get_level(State.LevelType.GLOBE)
	level.add_child.call_deferred(marker)
	await marker.tree_entered
	(marker as Node3D).global_position = State.local_sundial_data['position']

func _get_cancel_input() -> void:
	if Input.is_action_just_pressed("ui_cancel") and !transitioning:
		_exit_globe_scene()

func _exit_globe_scene() -> void:
	State.local_sundial_data = {}

	var scene_manager: SceneManager = Group.first("scene_manager")
	await (scene_manager as SceneManager).switch_scene(
		SceneManager.Scenes.GAME,
		before_cancel_cmd, 
		after_cancel_cmd
	)

func exit_mode() -> void:
	menu_layer.toggle_main_menu_allowed = true
	await hud_layer.hide_instruction_panel()
