class_name PlayerSundialController extends PlayerController

@export_group("References")
@export var actor: SundialManager

func _ready() -> void:
	assert(actor)

func player_input_process(_delta: float) -> void:
	_get_exit_sundial_input()

func _get_exit_sundial_input() -> void:
	if Input.is_action_just_pressed("toggle_boat_sundial"):
		if (State.game_pam as PlayerActorManager).transitioning: return

		var prev_pd: PlayerActorManager.PlayerData = State.game_pam.previous_player_data
		State.game_pam.change_player_data(prev_pd)