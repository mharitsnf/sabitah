class_name PlayerSundialController extends PlayerController

@export_group("References")
@export var actor: SundialManager

const SUNDIAL_ROTATION_STEP: float = deg_to_rad(15)

func _ready() -> void:
	super()
	assert(actor)

func enter_controller() -> void:
	Common.InputPromptManager.add_to_hud_layer(hud_layer, [
		'T_Exit', 'Q/E', 'A/D'
	])

	Common.InputPromptManager.show_input_prompt([
		'T_Exit', 'Q/E', 'A/D'
	])

	(hud_layer as GameHUDLayer).show_time_container()

func exit_controller() -> void:
	Common.InputPromptManager.remove_from_hud_layer(hud_layer, [
		'T_Exit', 'Q/E', 'A/D'
	])

	(hud_layer as GameHUDLayer).hide_time_container()

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
