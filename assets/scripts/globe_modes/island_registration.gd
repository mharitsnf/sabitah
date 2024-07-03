class_name IslandRegistration extends LatLongSearch

@export_group("References")
@export var level_anim: AnimationPlayer
@export var tpc: ThirdPersonCamera
@export_subgroup("Packed scenes")
@export var first_marker_pscn: PackedScene

## Margin of error for the player.
const ISLAND_REGISTRATION_MARGIN_OF_ERROR: float = 500.

func _ready() -> void:
	super()

	assert(level_anim)
	assert(tpc)
	assert(first_marker_pscn)

func enter_mode() -> void:
	menu_layer.toggle_main_menu_allowed = false
	hud_layer.show_instruction_panel()

func player_input_process(_delta: float) -> void:
	_get_confirm_island_location_input()

func _get_confirm_island_location_input() -> void:
	if Input.is_action_just_pressed("confirm_island_location") and !transitioning:
		var query_latlong: Array = Common.Geometry.point_to_latlng(planet_query_res['normal'])
		var dist: float = Common.Geometry.haversine_dist(
			State.local_sundial_data['lat'],
			State.local_sundial_data['long'],
			query_latlong[0],
			query_latlong[1],
			State.PLANET_RADIUS
		)
		
		if dist < ISLAND_REGISTRATION_MARGIN_OF_ERROR:
			assert(State.local_sundial)

			State.local_sundial.first_marker_done = true

			var euler: Array = Common.Geometry.normal_to_degrees(State.local_sundial_data['normal'])
			tpc.set_euler_rotation(euler[0], euler[1])

			transitioning = true
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

func hide_crosshair() -> void:
	await hud_layer.hide_crosshair()

func show_crosshair() -> void:
	await hud_layer.show_crosshair()

func add_first_marker() -> void:
	var marker: IslandMarker = first_marker_pscn.instantiate()
	(marker as IslandMarker).sundial_manager = State.local_sundial
	var level: Node = State.get_level(State.LevelType.GLOBE)
	level.add_child.call_deferred(marker)
	await marker.tree_entered
	(marker as Node3D).global_position = State.local_sundial_data['position']

func _exit_globe_scene() -> void:
	State.local_sundial_data = {}
	await super()

func exit_mode() -> void:
	menu_layer.toggle_main_menu_allowed = true
	await hud_layer.hide_instruction_panel()

func _enter_tree() -> void:
	transitioning = false
