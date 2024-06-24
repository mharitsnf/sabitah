class_name PlayerSundialController extends PlayerController

@export_group("References")
@export var actor: SundialManager

const SUNDIAL_ROTATION_STEP: float = deg_to_rad(15)

func _ready() -> void:
	assert(actor)

func player_input_process(_delta: float) -> void:
	_get_exit_sundial_input()
	_get_rotate_latmes_input()
	_get_rotate_sundial_input()

func _get_exit_sundial_input() -> void:
	if Input.is_action_just_pressed("toggle_boat_sundial"):
		if (State.game_pam as PlayerActorManager).transitioning: return

		var prev_pd: PlayerActorManager.PlayerData = State.game_pam.previous_player_data
		State.game_pam.change_player_data(prev_pd)

func _get_rotate_latmes_input() -> void:
	var amount: float = Input.get_axis("rotate_latmes_left", "rotate_latmes_right")
	actor.rotate_latmes(amount)

func _get_rotate_sundial_input() -> void:
	if Input.is_action_just_pressed("rotate_sundial_left"):
		actor.rotate_sundial(-SUNDIAL_ROTATION_STEP)
	if Input.is_action_just_pressed("rotate_sundial_right"):
		actor.rotate_sundial(SUNDIAL_ROTATION_STEP)