class_name IslandRegistration extends LatLongSearch

@export_group("References")
@export var island_markers_parent: Node3D
@export var level_anim: AnimationPlayer
@export var tpc: ThirdPersonCamera

## Margin of error for the player.
const ISLAND_REGISTRATION_MARGIN_OF_ERROR: float = 500.

# region Lifecycle functions

func _enter_tree() -> void:
	transitioning = false

func _ready() -> void:
	super()

	assert(level_anim)
	assert(tpc)

func enter_controller() -> void:
	menu_layer.toggle_main_menu_allowed = false
	hud_layer.show_instruction_panel()

func exit_controller() -> void:
	menu_layer.toggle_main_menu_allowed = true
	await hud_layer.hide_instruction_panel()

func bool_unhandled_input(event: InputEvent) -> bool:
	if !super(event): return false
	
	if event.is_action_pressed("globe__confirm_island_registration") and !transitioning:
		_confirm_island_location()
		return false

	return true

func player_unhandled_input(event: InputEvent) -> void:
	bool_unhandled_input(event)

# region Island registration functions

func _confirm_island_location() -> void:
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

		transitioning = true
		level_anim.play("add_first_marker")
		await level_anim.animation_finished
		
		if State.sundial_groups['tutorial_island_sundial_manager'].has(State.local_sundial):
			ProgressState.global_progress['tutorial_island_registered'] = true
		
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
	var marker: IslandMarker = Common.Draw.create_island_first_marker(State.local_sundial)
	island_markers_parent.add_child.call_deferred(marker)
	await marker.tree_entered
	(marker as Node3D).global_position = State.local_sundial_data['marker_position']

func _exit_globe_scene() -> void:
	State.local_sundial_data = {}
	await super()