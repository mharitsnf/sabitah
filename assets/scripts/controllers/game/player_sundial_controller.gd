class_name PlayerSundialController extends PlayerController

@export_group("References")
@export var actor: SundialManager

const SUNDIAL_ROTATION_STEP: float = deg_to_rad(15)

func _ready() -> void:
	super()
	assert(actor)

func enter_controller() -> void:
	for ip: InputPrompt in input_prompts.values():
		if ip.active: hud_layer.add_input_prompt(ip)

	(hud_layer as GameHUDLayer).show_time_container()

func exit_controller() -> void:
	for ip: InputPrompt in input_prompts.values():
		hud_layer.remove_input_prompt(ip)

	(hud_layer as GameHUDLayer).hide_time_container()

func _add_input_prompts() -> void:
	super()

	(input_prompts['RMB'] as InputPrompt).active = false

	var ip_factory: Common.InputPromptFactory = Common.InputPromptFactory.new()
	ip_factory.set_data("T", "Exit sundial", true)
	input_prompts['T'] = ip_factory.get_instance()

	ip_factory.set_data("Q/E", "Spin sundial", true)
	input_prompts['Q/E'] = ip_factory.get_instance()

	ip_factory.set_data("A/D", "Rotate latitude measure", true)
	input_prompts['A/D'] = ip_factory.get_instance()

func player_input_process(_delta: float) -> void:
	_get_exit_sundial_input()
	_get_rotate_latmes_input()
	_get_rotate_sundial_input()

func _get_exit_sundial_input() -> void:
	if Input.is_action_just_pressed("actor__toggle_sundial"):
		if (State.actor_im as ActorInputManager).transitioning: return

		var prev_pd: ActorData = (State.actor_im as ActorInputManager).previous_data
		State.actor_im.switch_data(prev_pd)

func _get_rotate_latmes_input() -> void:
	var amount: float = Input.get_axis("sundial__spin_left", "sundial__spin_right")
	actor.rotate_latmes(amount)

func _get_rotate_sundial_input() -> void:
	if Input.is_action_just_pressed("sundial__rotate_left"):
		actor.rotate_sundial(-SUNDIAL_ROTATION_STEP)
	if Input.is_action_just_pressed("sundial__rotate_right"):
		actor.rotate_sundial(SUNDIAL_ROTATION_STEP)
