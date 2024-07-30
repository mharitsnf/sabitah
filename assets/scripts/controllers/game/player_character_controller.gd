class_name PlayerCharacterController extends PlayerActorController

enum CharacterStates {
	GROUNDED, FALL, JUMP
}

@export var states: Array[ActorState]
@export_group("Parameters")
@export_subgroup("First person camera clamp settings")
@export var ground_clamp_settings: CameraClampSettings
@export var water_clamp_settings: CameraClampSettings
@export_subgroup("Camera offset")
@export var ground_offset: Vector3
@export var water_offset: Vector3
@export_subgroup("Registering island")
@export var to_island_registration_cmd: Command
@export_group("References")
@export var actor: CharacterActor
@export var tpc: ThirdPersonCamera
@export var fpc: FirstPersonCamera

# Refs from group
var interact_areas: Array[InteractArea]

var player_boat_area: Area3D
var clue_areas: Array[ClueArea]

var prev_actor_state: ActorState
var current_actor_state: ActorState

var jump_variable: float = 0.

var h_input: Vector2

var inside_player_boat_area: bool = false
var enter_boat_input_prompt: InputPrompt

var ignore_area_check_time_elapsed: float = 0.
const IGNORE_AREA_CHECK_DURATION: float = .25

var input_prompt_state: Dictionary = {
	"F_Enter": false,
	"T_Enter": false,
	"Y": false,
	"C": true,
	"G_Register": false,
	"E_Interact": false
}

# region Lifecycle functions

func _enter_tree() -> void:
	_remove_register_island_input_prompt()

func _ready() -> void:
	super()

	player_boat_area = Group.first("player_boat_area")

	assert(to_island_registration_cmd)
	assert(actor)
	assert(player_boat_area)

	current_actor_state = get_character_state(CharacterStates.FALL)

func enter_controller() -> void:
	super()
	Common.InputPromptManager.add_to_hud_layer(hud_layer, [
		"F_Enter", "T_Enter", "Y", "C", "G_Register", "E_Interact"
	])

	Common.InputPromptManager.show_input_prompt([
		"RMB_Enter"
	])

func exit_controller() -> void:
	super()
	Common.InputPromptManager.remove_from_hud_layer(hud_layer, [
		"F_Enter", "T_Enter", "Y", "C", "G_Register", "E_Interact"
	])

	ignore_area_check_time_elapsed = 0.

func _process(_delta: float) -> void:
	actor.rotate_visuals(main_camera.global_basis, h_input)

func _physics_process(delta: float) -> void:
	var y_rot_target: Node3D = main_camera.follow_target.y_rot_target
	var ref_basis: Basis = y_rot_target.global_basis
	if actor.is_on_slope(): ref_basis = Basis(Common.Geometry.recalculate_quaternion(main_camera.global_basis, actor.ground_normal)).orthonormalized()
	actor.move(ref_basis, h_input)

	if current_actor_state:
		current_actor_state.delegated_physics_process(delta)

func delegated_process(delta: float) -> void:
	if ignore_area_check_time_elapsed < IGNORE_AREA_CHECK_DURATION:
		ignore_area_check_time_elapsed += delta

	if actor.is_submerged():
		tpc.offset = water_offset
		fpc.clamp_settings = water_clamp_settings
	else:
		tpc.offset = ground_offset
		fpc.clamp_settings = ground_clamp_settings

	if current_actor_state:
		current_actor_state.delegated_process(delta)
		current_actor_state.player_input_process(delta)

func player_input_process(_delta: float) -> void:
	_get_register_boat_waypoint_input()
	_get_enter_register_island_input()
	_get_enter_local_sundial_input()
	_get_check_clues_input()
	_get_enter_ship_input()
	_get_h_input()

func player_unhandled_input(event: InputEvent) -> void:
	_get_interact_input(event)
	if current_actor_state:
		current_actor_state.player_unhandled_input(event)

func switch_state(new_state: ActorState) -> void:
	if current_actor_state:
		current_actor_state.exit_state()
		prev_actor_state = current_actor_state

	current_actor_state = new_state
	new_state.enter_state()

# region input prompts

func _remove_register_island_input_prompt() -> void:
	if State.local_sundial and State.local_sundial.first_marker_done:
		Common.InputPromptManager.remove_from_hud_layer.call_deferred(["Y"])

# region Setters and getters

func get_character_state(key: CharacterStates) -> ActorState:
	return states[key]

func _set_input_prompt_state(key: String, value: bool) -> void:
	input_prompt_state[key] = value
	if value:
		if (State.actor_im as ActorInputManager).is_entry_camera_active():
			Common.InputPromptManager.show_input_prompt([key])
	else:
		Common.InputPromptManager.hide_input_prompt([key])

# region Input functions

func _get_enter_register_island_input() -> void:

	if Input.is_action_just_pressed("globe__enter_island_registration_mode"):
		if !_character_interaction_allowed(): return
		if !ProgressState.get_progress(['tutorial_island', 'teacher', 'sundial_intro']): return
		if !State.local_sundial: return
		if State.local_sundial.first_marker_done: return

		# Fill local sundial data
		var latlong: Array = State.local_sundial.latlong
		var planet_data: Dictionary = State.get_planet_data(State.LevelType.GLOBE)
		State.local_sundial_data = {
			"marker_position": State.local_sundial.global_position.normalized() * planet_data['radius'],
			"normal": State.local_sundial.global_position.normalized(),
			"lat": latlong[0],
			"long": latlong[1],
		}
	
		# Switch to globe
		var scene_manager: SceneManager = Group.first("scene_manager")
		(scene_manager as SceneManager).switch_scene(
			SceneManager.Scenes.GLOBE, 
			null, 
			to_island_registration_cmd
		)

func _get_register_boat_waypoint_input() -> void:
	if Input.is_action_just_pressed("actor__register_boat_waypoint"):
		if !_character_interaction_allowed(): return
		if !ProgressState.get_progress(['tutorial_island', 'teacher', 'sundial_intro']): return
		if !State.local_sundial: return
		if !State.local_sundial.first_marker_done: return

		Common.DialogueWrapper.start_monologue("set_node_sundial")

func _get_enter_local_sundial_input() -> void:
	if Input.is_action_just_pressed("actor__toggle_sundial"):
		if !_character_interaction_allowed(): return
		if !State.local_sundial: return

		var new_pd: ActorData = ActorData.new()
		new_pd.set_instance(State.local_sundial)
		State.actor_im.switch_data(new_pd)

## Input for checking if clue is corect or not
func _get_check_clues_input() -> void:
	if Input.is_action_just_pressed("clue__check_area"):
		if !_character_interaction_allowed(): return
		if clue_areas.is_empty():
			ClueState.has_reward = false
		else:
			ClueState.has_reward = true
			for area: ClueArea in clue_areas:
				if !ClueState.is_clue_area_valid(area): continue
				var cd: ClueData = ClueState.get_clue_data_by_area(area)
				var reward_info: Dictionary = ClueState.unlock_reward(cd.get_clue().id)
				if !reward_info.is_empty():
					ClueState.rewards_info.append(reward_info)
				cd.set_clue_area_monitorable(false)

		Common.DialogueWrapper.start_dialogue.call_deferred(ClueState.check_dialogue, "start")

func _get_enter_ship_input() -> void:
	if Input.is_action_just_pressed("actor__toggle_boat"):
		if !_character_interaction_allowed(): return
		if !inside_player_boat_area: return
		
		if !ProgressState.get_global_progress(['boat_key_received']):
			Common.DialogueWrapper.start_monologue("boat_key_not_received")
			return

		if !ProgressState.get_global_progress(['tutorial_island_registered']):
			Common.DialogueWrapper.start_monologue("tutorial_island_not_registered")
			return

		if !ProgressState.get_global_progress(['boat_key_fixed']):
			Common.DialogueWrapper.start_monologue("boat_key_not_fixed")
			return
		
		var boat_pd: ActorData = State.actor_im.get_player_data(ActorInputManager.PlayerActors.BOAT)
		var res: Array = await State.actor_im.switch_data(boat_pd)
		if res[0]:
			State.actor_im.remove_child.call_deferred((res[1] as ActorData).get_instance())

func _get_interact_input(event: InputEvent) -> void:
	if event.is_action_pressed("actor__interact"):
		if !_character_interaction_allowed(): return
		if interact_areas.is_empty(): return
		var ia: InteractArea = interact_areas.back()
		Common.DialogueWrapper.start_dialogue(ia.dialogue_resource, "start")

func _get_h_input() -> void:
	h_input = Input.get_vector("character__move_left", "character__move_right", "character__move_backward", "character__move_forward")

func _character_interaction_allowed() -> bool:
	if Common.DialogueWrapper.is_dialogue_active(): return false
	if !(State.actor_im as ActorInputManager).is_entry_camera_active(): return false
	return true

# region Signal listener functions.

func _reset_inputs() -> void:
	h_input = Vector2.ZERO

func _on_follow_target_changed(new_vc: VirtualCamera) -> void:
	if (State.actor_im as ActorInputManager).get_current_controller() != self: return
	if new_vc is FirstPersonCamera:
		Common.InputPromptManager.hide_input_prompt(["RMB_Enter", "F_Enter", "T_Enter", "Y", "C", "G_Register", "E_Interact"])
		Common.InputPromptManager.show_input_prompt(["RMB_Exit", "LMB_Picture"])
	else:
		var active_prompts: Array = input_prompt_state.keys().filter(
			func (key: String) -> bool:
				return input_prompt_state[key] == true
		)
		Common.InputPromptManager.hide_input_prompt(["RMB_Exit", "LMB_Picture"])
		Common.InputPromptManager.show_input_prompt(["RMB_Enter"] + active_prompts)

func _on_local_sundial_area_entered(area: Node3D) -> void:
	var area_parent: Node = area.get_parent()
	if !(area_parent is LocalSundialManager): return
	
	State.local_sundial = area_parent
	_set_input_prompt_state("T_Enter", true)
	
	if !ProgressState.get_progress(['tutorial_island', 'teacher', 'sundial_intro']): return

	if !State.local_sundial.first_marker_done:
		_set_input_prompt_state("Y", true)
	else:
		_set_input_prompt_state("G_Register", true)

func _on_local_sundial_area_exited(_area: Node3D) -> void:
	if State.local_sundial_data.is_empty(): State.local_sundial = null
	_set_input_prompt_state("T_Enter", false)

	if !ProgressState.get_progress(['tutorial_island', 'teacher', 'sundial_intro']): return

	_set_input_prompt_state("Y", false)
	_set_input_prompt_state("G_Register", false)

func _on_player_boat_area_entered() -> void:
	inside_player_boat_area = true
	_set_input_prompt_state("F_Enter", true)

func _on_player_boat_area_exited() -> void:
	inside_player_boat_area = false
	_set_input_prompt_state("F_Enter", false)

func _on_area_checker_area_entered(area: Area3D) -> void:
	if area.is_in_group("clue_areas"):
		clue_areas.append(area)
		return

	if area.is_in_group("local_sundial_areas"):
		_on_local_sundial_area_entered(area)
		return

	if area.is_in_group("player_boat_area"):
		_on_player_boat_area_entered()
		return

	if area.is_in_group("island_areas"):
		if ignore_area_check_time_elapsed < IGNORE_AREA_CHECK_DURATION: return
		if State.actor_im.get_current_controller() != self: return

		assert(area.get_parent() is LocalSundialManager)
		var lsm: LocalSundialManager = area.get_parent()
		if !(lsm as LocalSundialManager).first_marker_done: return

		(hud_layer as GameHUDLayer).set_island_name_label_text((lsm as LocalSundialManager).get_island_name())
		(hud_layer as GameHUDLayer).show_island_name()
		return

	if area.is_in_group("interact_areas"):
		interact_areas.append(area)
		_set_input_prompt_state("E_Interact", true)
		return

func _on_area_checker_area_exited(area: Area3D) -> void:
	if area.is_in_group("clue_areas"):
		clue_areas.erase(area)
		return

	if area.is_in_group("local_sundial_areas"):
		_on_local_sundial_area_exited(area)
		return

	if area.is_in_group("player_boat_area"):
		_on_player_boat_area_exited()
		return
	
	if area.is_in_group("interact_areas"):
		interact_areas.erase(area)
		_set_input_prompt_state("E_Interact", false)
		return
