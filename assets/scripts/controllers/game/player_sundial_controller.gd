class_name PlayerSundialController extends PlayerController

@export_group("References")
@export var actor: SundialManager

const SUNDIAL_ROTATION_STEP: float = deg_to_rad(15)

func _ready() -> void:
	super()

	assert(actor)

func enter_controller() -> void:
	if input_prompts.is_empty():
		var ip_factory: Common.InputPromptFactory = Common.InputPromptFactory.new()
		
		ip_factory.set_input_button("T")
		ip_factory.set_prompt("Exit sundial")
		ip_factory.set_active(true)
		input_prompts.append(ip_factory.get_instance())

		ip_factory.set_input_button("Q/E")
		ip_factory.set_prompt("Rotate sundial")
		ip_factory.set_active(true)
		input_prompts.append(ip_factory.get_instance())

		ip_factory.set_input_button("A/D")
		ip_factory.set_prompt("Rotate latitude measure")
		ip_factory.set_active(true)
		input_prompts.append(ip_factory.get_instance())

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
		if (State.actor_im as ActorInputManager).transitioning: return

		var prev_pd: ActorData = (State.actor_im as ActorInputManager).previous_data
		State.actor_im.switch_data(prev_pd)

func _get_rotate_latmes_input() -> void:
	var amount: float = Input.get_axis("rotate_latmes_left", "rotate_latmes_right")
	actor.rotate_latmes(amount)

func _get_rotate_sundial_input() -> void:
	if Input.is_action_just_pressed("rotate_sundial_left"):
		actor.rotate_sundial(-SUNDIAL_ROTATION_STEP)
	if Input.is_action_just_pressed("rotate_sundial_right"):
		actor.rotate_sundial(SUNDIAL_ROTATION_STEP)