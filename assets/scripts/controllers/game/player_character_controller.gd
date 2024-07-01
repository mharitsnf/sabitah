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

# Refs from group
var main_camera: MainCamera
var player_boat_area: Area3D

var prev_actor_state: ActorState
var current_actor_state: ActorState

var jump_variable: float = 0.

var h_input: Vector2

var inside_player_boat_area: bool = false
var enter_boat_input_prompt: InputPrompt

# region Entry functions

func _enter_tree() -> void:
	_evaluate_register_island_input_prompt()

func _ready() -> void:
	super()

	main_camera = Group.first("main_camera")
	player_boat_area = Group.first("player_boat_area")

	assert(to_island_registration_cmd)
	assert(actor)
	assert(main_camera)
	assert(main_camera is MainCamera)
	assert(player_boat_area)

	(State.actor_im as ActorInputManager).current_data_changed.connect(_on_current_data_changed)
	(player_boat_area as Area3D).body_entered.connect(_on_body_entered_player_boat_area)
	(player_boat_area as Area3D).body_exited.connect(_on_body_exited_player_boat_area)

	for area: Area3D in Group.all("local_sundial_areas"):
		area.body_entered.connect(_on_body_entered_local_sundial_area.bind(area))
		area.body_exited.connect(_on_body_exited_local_sundial_area)

	current_actor_state = get_character_state(CharacterStates.FALL)

func enter_controller() -> void:
	# Instantiate input prompts
	if input_prompts.is_empty():
		# Create enter ship input prompt
		var enter_ship_ip: InputPrompt = State.input_prompt_pscn.instantiate()
		(enter_ship_ip as InputPrompt).input_button = "F"
		(enter_ship_ip as InputPrompt).prompt = "Enter ship"
		input_prompts.append(enter_ship_ip)

		# Create enter ship input prompt
		var enter_local_sundial_ip: InputPrompt = State.input_prompt_pscn.instantiate()
		(enter_local_sundial_ip as InputPrompt).input_button = "T"
		(enter_local_sundial_ip as InputPrompt).prompt = "Enter local sundial"
		input_prompts.append(enter_local_sundial_ip)

		# Create enter ship input prompt
		var enter_register_island_ip: InputPrompt = State.input_prompt_pscn.instantiate()
		(enter_register_island_ip as InputPrompt).input_button = "Y"
		(enter_register_island_ip as InputPrompt).prompt = "Register island"
		input_prompts.append(enter_register_island_ip)

	_add_input_prompts()

func _evaluate_register_island_input_prompt() -> void:
	if input_prompts.is_empty(): return

	if State.local_sundial and State.local_sundial.first_marker_done:
		if !(input_prompts[2] as InputPrompt).is_inside_tree():
			await (input_prompts[2] as InputPrompt).tree_entered
		(input_prompts[2] as InputPrompt).active = false
		hud_layer.remove_input_prompt((input_prompts[2] as InputPrompt))

func _add_input_prompts() -> void:
	for ip: InputPrompt in input_prompts:
		if ip.active:
			hud_layer.add_input_prompt(ip)

func exit_controller() -> void:
	for ip: InputPrompt in input_prompts:
		hud_layer.remove_input_prompt(ip)

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
	if current_actor_state:
		current_actor_state.delegated_process(delta)
		current_actor_state.player_input_process(delta)

func player_input_process(_delta: float) -> void:
	_get_enter_register_island_input()
	_get_enter_local_sundial_input()
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

	if Input.is_action_just_pressed("enter_island_registration"):
		# Fill local sundial data
		var latlong: Array = Common.Geometry.point_to_latlng(State.local_sundial.global_position.normalized())
		State.local_sundial_data = {
			"position": State.local_sundial.global_position.normalized() * State.PLANET_RADIUS * State.MAIN_TO_GLOBE_SCALE,
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

func _get_enter_local_sundial_input() -> void:
	if (State.actor_im as ActorInputManager).transitioning: return
	if Input.is_action_just_pressed("toggle_sundial") and State.local_sundial:
		var new_pd: ActorData = ActorData.new()
		new_pd.set_instance(State.local_sundial)
		State.actor_im.switch_data(new_pd)

func _get_enter_ship_input() -> void:
	if (State.actor_im as ActorInputManager).transitioning: return
	if Input.is_action_just_pressed("switch_boat_character") and inside_player_boat_area:
		var boat_pd: ActorData = State.actor_im.get_player_data(ActorInputManager.PlayerActors.BOAT)
		var res: Array = await State.actor_im.switch_data(boat_pd)
		if res[0]:
			State.actor_im.remove_child.call_deferred((res[1] as ActorData).get_instance())

func _get_h_input() -> void:
	h_input = Input.get_vector("character_left", "character_right", "character_backward", "character_forward")

# region Signal listener functions.

func _on_current_data_changed() -> void:
	if State.actor_im.get_current_controller() != self:
		h_input = Vector2.ZERO

func _on_body_entered_local_sundial_area(body: Node3D, area: Node3D) -> void:
	if body != actor: return
	
	var area_parent: Node = area.get_parent()
	if !(area_parent is LocalSundialManager): return
	
	State.local_sundial = area_parent
	(input_prompts[1] as InputPrompt).active = true
	hud_layer.add_input_prompt(input_prompts[1])
	
	if State.local_sundial.first_marker_done: return

	(input_prompts[2] as InputPrompt).active = true
	hud_layer.add_input_prompt(input_prompts[2])

func _on_body_exited_local_sundial_area(body: Node3D) -> void:
	if body != actor: return
	if State.local_sundial_data.is_empty(): State.local_sundial = null
	(input_prompts[1] as InputPrompt).active = false
	hud_layer.remove_input_prompt(input_prompts[1])

	(input_prompts[2] as InputPrompt).active = false
	hud_layer.remove_input_prompt(input_prompts[2])

func _on_body_entered_player_boat_area(body: Node3D) -> void:
	if body == actor:
		inside_player_boat_area = true
		hud_layer.add_input_prompt(input_prompts[0])

func _on_body_exited_player_boat_area(body: Node3D) -> void:
	if body == actor:
		inside_player_boat_area = false
		hud_layer.remove_input_prompt(input_prompts[0])
