class_name PlayerBoatActor extends BoatActor

@export var dropoff_point: Marker3D

var forward_input: float = 0.
var brake_input: float = 0.
var lr_input: float = 0.

func _physics_process(_delta: float) -> void:
	_move_forward(normal_target.global_basis, forward_input)
	_brake(brake_input)

func _process(_delta: float) -> void:
	_rotate_visuals(lr_input)

func player_input_process(_delta: float) -> void:
	_get_exit_boat_input()
	_get_forward_input()
	_get_brake_input()
	_get_lr_input()

func _get_exit_boat_input() -> void:
	if Input.is_action_just_pressed("switch_actor"):
		if State.game_pam.transitioning: return
		
		var next_pd: PlayerActorManager.PlayerData = State.game_pam.get_player_data(PlayerActorManager.PlayerActors.CHARACTER)
		next_pd.get_instance().position = dropoff_point.global_position
		State.game_pam.change_player_data(next_pd)

## Private. Polls the gas / forward input from the player.
func _get_forward_input() -> void:
	forward_input = Input.get_action_strength("boat_forward")

## Private. Polls the brake input from the player.
func _get_brake_input() -> void:
	brake_input = Input.get_action_strength("boat_backward")

## Private. Polls the rotate boat input from the player.
func _get_lr_input() -> void:
	lr_input = Input.get_axis("boat_left", "boat_right")
