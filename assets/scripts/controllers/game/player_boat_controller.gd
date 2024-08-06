class_name PlayerBoatController extends PlayerActorController

@export_group("References")
@export var boat_sundial_manager: SundialManager
@export var dropoff_marker: Marker3D
@export var actor: BoatActor

var gas_input: float = 0.
var rotate_input: float = 0.
var brake_input: float = 0.

# region Entry functions

func _ready() -> void:
	super()

	assert(boat_sundial_manager)
	assert(dropoff_marker)
	assert(actor)

	State.teleport_to_node_sundial.connect(_on_teleport_to_node_sundial)

func enter_controller() -> void:
	super()
	Common.InputPromptManager.add_to_hud_layer(hud_layer, [
		'F_Exit', 'T_Enter', 'G_Teleport'
	])

	Common.InputPromptManager.show_input_prompt([
		'F_Exit', 'T_Enter', 'G_Teleport'
	])

func exit_controller() -> void:
	super()
	Common.InputPromptManager.remove_from_hud_layer(hud_layer, [
		'F_Exit', 'T_Enter', 'G_Teleport'
	])

# region Lifecycle functions

func _process(_delta: float) -> void:
	actor.rotate_visuals(rotate_input)
	actor.show_trail_particles(gas_input)

	# Called when this controller is inactive
	_reset_rotate_input_smooth()

func _physics_process(_delta: float) -> void:
	actor.move_forward(actor.normal_target.global_basis, gas_input)
	if brake_input > 0.: actor.brake(brake_input)

func player_input_process(_delta: float) -> void:
	_get_teleport_to_waypoint_input()
	_get_enter_sundial_input()
	_get_exit_ship_input()
	_get_gas_input()
	_get_rotate_input()

# region Input functions

func _get_enter_sundial_input() -> void:
	if Input.is_action_just_pressed("actor__toggle_sundial"):
		if !_boat_interaction_allowed(): return

		var new_pd: ActorData = ActorData.new()
		new_pd.set_instance(boat_sundial_manager)
		var new_pcm: PlayerCameraManager = new_pd.get_camera_manager()

		State.actor_im.switch_data(new_pd)
		main_camera.follow_target = new_pcm.get_entry_camera()

func _get_exit_ship_input() -> void:
	if Input.is_action_just_pressed("actor__toggle_boat"):
		if !_boat_interaction_allowed(): return
		
		# get actor data for character
		var char_pd: ActorData = (State.actor_im as ActorInputManager).get_player_data(ActorInputManager.PlayerActors.CHARACTER)
		var char_pcm: PlayerCameraManager = char_pd.get_camera_manager()
		
		# Add character to the level
		var char_inst: Node3D = char_pd.get_instance()
		State.actor_im.add_child.call_deferred(char_inst)
		if !char_inst.is_node_ready(): await char_inst.ready
		else: await char_inst.tree_entered
		(char_inst as BaseActor).setup_spawn(dropoff_marker.global_position)

		# setup camera
		var entry_cam: VirtualCamera = char_pcm.get_entry_camera()
		char_pcm.set_current_camera(entry_cam)
		entry_cam.copy_rotation(main_camera.follow_target)
		main_camera.follow_target = entry_cam

		# Switch to the character's actor data
		State.actor_im.switch_data(char_pd)

func _get_teleport_to_waypoint_input() -> void:
	if Input.is_action_just_pressed("boat__teleport_to_waypoint"):
		if !_boat_interaction_allowed(): return
		if !ProgressState.get_global_progress(["first_sundial_registered"]): return

		Common.DialogueWrapper.start_monologue("teleport_to_node_island")

func _get_brake_input() -> void:
	if !ProgressState.get_global_progress(["first_sundial_registered"]): return
	brake_input = Input.get_action_strength("boat__brake")

func _get_gas_input() -> void:
	if !ProgressState.get_global_progress(["first_sundial_registered"]): return
	gas_input = Input.get_action_strength("boat__move_forward")

func _get_rotate_input() -> void:
	if !ProgressState.get_global_progress(["first_sundial_registered"]): return
	rotate_input = Input.get_axis("boat__turn_left", "boat__turn_right")

func _boat_interaction_allowed() -> bool:
	if !(State.actor_im as ActorInputManager).is_entry_camera_active(): return false
	if (State.actor_im as ActorInputManager).transitioning: return false
	return true

# region Signal listener functions

func _on_follow_target_changed(new_vc: VirtualCamera) -> void:
	if (State.actor_im as ActorInputManager).get_current_controller() != self: return
	if new_vc is FirstPersonCamera:
		Common.InputPromptManager.hide_input_prompt(["RMB_Enter", 'F_Exit', 'T_Enter', 'G_Teleport'])
		Common.InputPromptManager.show_input_prompt(["RMB_Exit", "LMB_Picture", 'V'])
	else:
		Common.InputPromptManager.hide_input_prompt(["RMB_Exit", "LMB_Picture", 'V'])
		Common.InputPromptManager.show_input_prompt(["RMB_Enter", 'F_Exit', 'T_Enter', 'G_Teleport'])

func _on_teleport_to_node_sundial() -> void:
	assert(State.node_sundial)
	var waypoint: Marker3D = State.node_sundial.boat_waypoint
	actor.setup_spawn.call_deferred(waypoint.global_position)

const ROTATION_INPUT_WEIGHT: float = 5.
func _reset_rotate_input_smooth() -> void:
	if State.actor_im.get_current_controller() != self:
		rotate_input = lerp(rotate_input, 0., get_process_delta_time() * ROTATION_INPUT_WEIGHT)

func _reset_inputs() -> void:
	gas_input = 0.
	brake_input = 0.
	rotate_input = 0.

func _on_area_checker_area_entered(area: Area3D) -> void:
	if area.is_in_group("island_areas"):
		if State.actor_im.get_current_controller() != self: return

		assert(area.get_parent() is LocalSundialManager)
		var lsm: LocalSundialManager = area.get_parent()
		if !(lsm as LocalSundialManager).first_marker_done: return

		(hud_layer as GameHUDLayer).set_island_name_label_text((lsm as LocalSundialManager).get_island_name())
		(hud_layer as GameHUDLayer).show_island_name()

func _on_area_checker_area_exited(area: Area3D) -> void:
	if area.is_in_group("island_areas"):
		pass
