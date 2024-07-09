class_name PlayerCharacterController extends PlayerController

enum CharacterStates {
	GROUNDED, FALL, JUMP
}

@export var states: Array[ActorState]
@export_group("Switch scene commands")
@export_subgroup("Registering island")
@export var to_island_registration_cmd: Command
@export_group("References")
@export var actor: CharacterActor
@export_subgroup("Packed scenes")
@export var node_sundial_dialogue: DialogueResource

# Refs from group
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

# region Entry functions

func _enter_tree() -> void:
	_remove_register_island_input_prompt()

func _ready() -> void:
	super()

	player_boat_area = Group.first("player_boat_area")

	assert(to_island_registration_cmd)
	assert(actor)
	assert(player_boat_area)
	assert(node_sundial_dialogue)

	current_actor_state = get_character_state(CharacterStates.FALL)

func enter_controller() -> void:
	for ip: InputPrompt in input_prompts.values():
		if ip.active:
			hud_layer.add_input_prompt(ip)

func _remove_register_island_input_prompt() -> void:
	if input_prompts.is_empty(): return

	if State.local_sundial and State.local_sundial.first_marker_done:
		if !(input_prompts["Y"] as InputPrompt).is_inside_tree():
			await (input_prompts["Y"] as InputPrompt).tree_entered
		(input_prompts["Y"] as InputPrompt).active = false
		hud_layer.remove_input_prompt((input_prompts["Y"] as InputPrompt))

func exit_controller() -> void:
	for ip: InputPrompt in input_prompts.values():
		hud_layer.remove_input_prompt(ip)
	ignore_area_check_time_elapsed = 0.

func _add_input_prompts() -> void:
	super()

	var ip_factory: Common.InputPromptFactory = Common.InputPromptFactory.new()
	ip_factory.set_data("F", "Enter ship")
	input_prompts['F'] = ip_factory.get_instance()

	ip_factory.set_data("T", "Enter local sundial")
	input_prompts['T'] = ip_factory.get_instance()

	ip_factory.set_data("Y", "Register island")
	input_prompts['Y'] = ip_factory.get_instance()

	ip_factory.set_data("C", "Confirm clue", true)
	input_prompts['C'] = ip_factory.get_instance()

	ip_factory.set_data("G", "Register boat waypoint", false)
	input_prompts['G'] = ip_factory.get_instance()

# region Lifecycle functions

func _process(_delta: float) -> void:
	actor.rotate_visuals(main_camera.global_basis, h_input)

func _physics_process(delta: float) -> void:
	var ref_basis: Basis = main_camera.global_basis
	if actor.is_on_slope():
		ref_basis = Basis(Common.Geometry.recalculate_quaternion(main_camera.global_basis, actor.ground_normal)).orthonormalized()
	actor.move(ref_basis, h_input)

	if current_actor_state:
		current_actor_state.delegated_physics_process(delta)

func delegated_process(delta: float) -> void:
	if ignore_area_check_time_elapsed < IGNORE_AREA_CHECK_DURATION:
		ignore_area_check_time_elapsed += delta

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
	if current_actor_state:
		current_actor_state.player_unhandled_input(event)

func switch_state(new_state: ActorState) -> void:
	if current_actor_state:
		current_actor_state.exit_state()
		prev_actor_state = current_actor_state

	current_actor_state = new_state
	new_state.enter_state()

# region Setters and getters

func get_character_state(key: CharacterStates) -> ActorState:
	return states[key]

# region Input functions

func _get_enter_register_island_input() -> void:
	if !State.local_sundial: return
	if State.local_sundial.first_marker_done: return

	if Input.is_action_just_pressed("globe__enter_island_registration_mode"):
		# Fill local sundial data
		var latlong: Array = Common.Geometry.point_to_latlng(State.local_sundial.global_position.normalized())
		State.local_sundial_data = {
			"marker_position": State.local_sundial.global_position.normalized() * State.PLANET_RADIUS * State.MAIN_TO_GLOBE_SCALE,
			"normal": State.local_sundial.global_position.normalized(),
			"lat": latlong[0],
			"long": latlong[0],
		}

		# Switch to globe
		var scene_manager: SceneManager = Group.first("scene_manager")
		(scene_manager as SceneManager).switch_scene(
			SceneManager.Scenes.GLOBE, 
			null, 
			to_island_registration_cmd
		)

func _get_register_boat_waypoint_input() -> void:
	if !State.local_sundial: return
	if !State.local_sundial.first_marker_done: return
	if Input.is_action_just_pressed("actor__register_boat_waypoint"):
		Common.DialogueWrapper.start_dialogue(node_sundial_dialogue, "set_node_sundial")

func _get_enter_local_sundial_input() -> void:
	if !State.local_sundial: return
	if Input.is_action_just_pressed("actor__toggle_sundial"):
		var new_pd: ActorData = ActorData.new()
		new_pd.set_instance(State.local_sundial)
		State.actor_im.switch_data(new_pd)

## Input for checking if clue is corect or not
func _get_check_clues_input() -> void:
	if Input.is_action_just_pressed("clue__check_area"):
		menu_layer.navigate_to(State.UserInterfaces.CLUES_MENU, { 'is_confirmation': true })
		await (menu_layer as MenuLayer).menu_cleared
		
		var area: ClueArea = (ClueState.get_clue_data_from_id(ClueState.clue_id_to_confirm) as ClueData).get_clue_area()
		
		if (clue_areas.has(area)):
			ClueState.confirm_data.status = true
			ClueState.change_clue_status(ClueState.clue_id_to_confirm, ClueState.ClueStatus.COMPLETED)
			ClueState.unlock_reward()
		else: ClueState.confirm_data.status = false

		print("asdf")
		Common.DialogueWrapper.start_dialogue(ClueState.check_dialogue, "start")

func _get_enter_ship_input() -> void:
	if Input.is_action_just_pressed("actor__toggle_boat") and inside_player_boat_area:
		var boat_pd: ActorData = State.actor_im.get_player_data(ActorInputManager.PlayerActors.BOAT)
		var res: Array = await State.actor_im.switch_data(boat_pd)
		if res[0]:
			State.actor_im.remove_child.call_deferred((res[1] as ActorData).get_instance())

func _get_h_input() -> void:
	h_input = Input.get_vector("character__move_left", "character__move_right", "character__move_backward", "character__move_forward")

# region Signal listener functions.

func _reset_inputs() -> void:
	h_input = Vector2.ZERO

func _on_menu_entered(_data: MenuLayer.MenuData) -> void:
	_reset_inputs()

func _on_current_data_changed() -> void:
	if State.actor_im.get_current_controller() != self:
		_reset_inputs()

func _on_local_sundial_area_entered(area: Node3D) -> void:
	var area_parent: Node = area.get_parent()
	if !(area_parent is LocalSundialManager): return
	
	State.local_sundial = area_parent
	(input_prompts["T"] as InputPrompt).active = true
	hud_layer.add_input_prompt(input_prompts["T"])
	
	if !State.local_sundial.first_marker_done:
		(input_prompts["Y"] as InputPrompt).active = true
		hud_layer.add_input_prompt(input_prompts["Y"])
	else:
		(input_prompts["G"] as InputPrompt).active = true
		hud_layer.add_input_prompt(input_prompts["G"])

func _on_local_sundial_area_exited(_area: Node3D) -> void:
	if State.local_sundial_data.is_empty(): State.local_sundial = null
	(input_prompts["T"] as InputPrompt).active = false
	hud_layer.remove_input_prompt(input_prompts["T"])

	(input_prompts["Y"] as InputPrompt).active = false
	hud_layer.remove_input_prompt(input_prompts["Y"])

	(input_prompts["G"] as InputPrompt).active = false
	hud_layer.remove_input_prompt(input_prompts["G"])

func _on_player_boat_area_entered() -> void:
	inside_player_boat_area = true
	hud_layer.add_input_prompt(input_prompts["F"])

func _on_player_boat_area_exited() -> void:
	inside_player_boat_area = false
	hud_layer.remove_input_prompt(input_prompts["F"])

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