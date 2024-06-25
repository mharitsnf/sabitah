class_name PlayerCharacterController extends PlayerController

enum CharacterStates {
	GROUNDED, FALL, JUMP
}

@export var states: Array[ActorState]
@export_group("References")
@export var actor: CharacterActor

var main_camera: MainCamera
var player_boat_area: Area3D

var prev_actor_state: ActorState
var current_actor_state: ActorState

var jump_variable: float = 0.

var h_input: Vector2

var inside_player_boat_area: bool = false
var enter_boat_input_prompt: InputPrompt

func _ready() -> void:
	super()

	actor = get_parent()
	main_camera = Group.first("main_camera")
	player_boat_area = Group.first("player_boat_area")

	assert(actor)
	assert(actor is CharacterActor)
	assert(main_camera)
	assert(main_camera is MainCamera)
	assert(player_boat_area)

	State.game_pam.current_player_data_changed.connect(_on_current_player_data_changed)
	(player_boat_area as Area3D).body_entered.connect(_on_body_entered_player_boat_area)
	(player_boat_area as Area3D).body_exited.connect(_on_body_exited_player_boat_area)

	current_actor_state = get_character_state(CharacterStates.FALL)

func enter_controller() -> void:
	# Instantiate input prompts
	if input_prompts.is_empty():
		# Create enter ship input prompt
		var enter_ship_ip: InputPrompt = State.input_prompt_pscn.instantiate()
		(enter_ship_ip as InputPrompt).input_button = "F"
		(enter_ship_ip as InputPrompt).prompt = "Enter ship"
		input_prompts.append(enter_ship_ip)

func exit_controller() -> void:
	for ip: InputPrompt in input_prompts:
		hud_layer.remove_input_prompt(ip)

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
	_get_enter_ship_input()
	_get_h_input()

func player_unhandled_input(event: InputEvent) -> void:
	if current_actor_state:
		current_actor_state.player_unhandled_input(event)

func get_character_state(key: CharacterStates) -> ActorState:
	return states[key]

func switch_state(new_state: ActorState) -> void:
	if current_actor_state:
		current_actor_state.exit_state()
		prev_actor_state = current_actor_state

	current_actor_state = new_state
	new_state.enter_state()

func _get_enter_ship_input() -> void:
	if Input.is_action_just_pressed("switch_boat_character") and inside_player_boat_area:
		if (State.game_pam as PlayerActorManager).transitioning: return

		var boat_pd: PlayerActorManager.PlayerData = State.game_pam.get_player_data(PlayerActorManager.PlayerActors.BOAT)
		var res: Array = await State.game_pam.change_player_data(boat_pd)
		if res[0]:
			State.game_pam.remove_child.call_deferred((res[1] as PlayerActorManager.PlayerData).get_instance())

func _get_h_input() -> void:
	h_input = Input.get_vector("character_left", "character_right", "character_backward", "character_forward")

func _on_current_player_data_changed() -> void:
	if State.game_pam.current_player_data.get_controller() != self:
		h_input = Vector2.ZERO

func _on_body_entered_player_boat_area(body: Node3D) -> void:
	if body == actor:
		inside_player_boat_area = true
		hud_layer.add_input_prompt(input_prompts[0])

func _on_body_exited_player_boat_area(body: Node3D) -> void:
	if body == actor:
		inside_player_boat_area = false
		hud_layer.remove_input_prompt(input_prompts[0])
