class_name PlayerSundialController extends PlayerController

@export_group("References")
@export var actor: SundialManager

const SUNDIAL_ROTATION_STEP: float = deg_to_rad(15)

func _ready() -> void:
	super()

	assert(actor)

func enter_controller() -> void:
	if input_prompts.is_empty():
		var exit_sundial_ip: InputPrompt = State.input_prompt_pscn.instantiate()
		(exit_sundial_ip as InputPrompt).active = true
		(exit_sundial_ip as InputPrompt).input_button = "T"
		(exit_sundial_ip as InputPrompt).prompt = "Exit sundial"
		input_prompts.append(exit_sundial_ip)

		var rotate_sundial_ip: InputPrompt = State.input_prompt_pscn.instantiate()
		(rotate_sundial_ip as InputPrompt).active = true
		(rotate_sundial_ip as InputPrompt).input_button = "Q/E"
		(rotate_sundial_ip as InputPrompt).prompt = "Rotate sundial"
		input_prompts.append(rotate_sundial_ip)

		var rotate_latmes_ip: InputPrompt = State.input_prompt_pscn.instantiate()
		(rotate_latmes_ip as InputPrompt).active = true
		(rotate_latmes_ip as InputPrompt).input_button = "A/D"
		(rotate_latmes_ip as InputPrompt).prompt = "Rotate latitude measure"
		input_prompts.append(rotate_latmes_ip)

	for ip: InputPrompt in input_prompts:
		if ip.active: hud_layer.add_input_prompt(ip)

func exit_controller() -> void:
	for ip: InputPrompt in input_prompts:
		hud_layer.remove_input_prompt(ip)

func player_input_process(_delta: float) -> void:
	_get_exit_sundial_input()
	_get_rotate_latmes_input()
	_get_rotate_sundial_input()

func _get_exit_sundial_input() -> void:
	if Input.is_action_just_pressed("toggle_sundial"):
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