class_name PCJumpState extends PlayerCharacterState

## Controls the duration of which the jump state will not be switched out in the beginning.
@export var ignore_time_limit: float = .3
var ignore_time: float = 0.

func enter_state() -> void:
    actor.jump(controller.jump_variable)
    controller.jump_variable = 0.

func delegated_process(delta: float) -> void:
    if ignore_time < ignore_time_limit:
        ignore_time += delta
        return

    # Change to fall
    var flat_vel: Vector3 = actor.global_basis.inverse() * actor.linear_velocity
    if flat_vel.y < 0.:
        var next_state: ActorState = controller.get_character_state(PlayerCharacterController.CharacterStates.FALL)
        controller.switch_state(next_state)
        return

func exit_state() -> void:
    ignore_time = 0.