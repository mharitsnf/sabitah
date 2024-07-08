class_name PCFallState extends PlayerCharacterState

@export_group("Coyote time settings")
@export var coyote_time_limit: float = .1
var coyote_time: float = 0.

func enter_state() -> void:
	actor.linear_damp = actor.air_damp

func delegated_process(delta: float) -> void:
	if coyote_time < coyote_time_limit and Input.is_action_just_pressed("character__jump") and controller.prev_actor_state == controller.get_character_state(PlayerCharacterController.CharacterStates.GROUNDED):
		controller.jump_variable = 1.
		_switch_to_jump()
		return

	# Change to grounded if on ground
	if actor.is_grounded():
		var next_state: ActorState = controller.get_character_state(PlayerCharacterController.CharacterStates.GROUNDED)
		controller.switch_state(next_state)
		return

	# Change to grounded if on water
	if actor.is_submerged():
		var next_state: ActorState = controller.get_character_state(PlayerCharacterController.CharacterStates.GROUNDED)
		controller.switch_state(next_state)
		return

	coyote_time += delta

func exit_state() -> void:
	coyote_time = 0.