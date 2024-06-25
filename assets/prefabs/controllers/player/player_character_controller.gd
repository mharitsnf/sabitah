class_name PlayerCharacterController extends PlayerController

enum CharacterStates {
	GROUNDED, FALL, JUMP
}

@export var states: Array[ActorState]
@export_group("References")
@export var actor: CharacterActor

var main_camera: MainCamera

var prev_actor_state: ActorState
var current_actor_state: ActorState

var jump_variable: float = 0.

var h_input: Vector2

func _ready() -> void:
	actor = get_parent()
	main_camera = Group.first("main_camera")

	assert(actor)
	assert(actor is CharacterActor)
	assert(main_camera)
	assert(main_camera is MainCamera)

	State.game_pam.current_player_data_changed.connect(_on_current_player_data_changed)

	current_actor_state = get_character_state(CharacterStates.FALL)

func _process(_delta: float) -> void:
	actor.rotate_visuals(main_camera.global_basis, h_input)
	print(current_actor_state)

func _physics_process(delta: float) -> void:
	actor.move(main_camera.global_basis, h_input)

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
	if Input.is_action_just_pressed("switch_boat_character"):
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