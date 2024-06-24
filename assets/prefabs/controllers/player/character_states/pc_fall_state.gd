class_name PCFallState extends PlayerCharacterState

func delegated_process(_delta: float) -> void:
    # Change to grounded if on water
    if actor.is_submerged():
        var next_state: ActorState = controller.get_character_state(PlayerCharacterController.CharacterStates.GROUNDED)
        controller.switch_state(next_state)
        return