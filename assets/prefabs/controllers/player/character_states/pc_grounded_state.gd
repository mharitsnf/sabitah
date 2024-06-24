class_name PCGroundedState extends PlayerCharacterState

@export_group("Jump input settings")
## Controls the duration and strength of the jump.
@export var variable_time_limit: float = 0.075
## Curve to map the jump input hold duration to the actual jump strength.
@export var jump_curve: Curve

var variable_time: float = 0.
var jump_pressed: bool = false

func delegated_process(delta: float) -> void:
    # Change to grounded if on water
    if Input.is_action_just_pressed("character_jump"):
        jump_pressed = true
    
    if jump_pressed:
        # Player release the input earlier than the time limit
        if Input.is_action_just_released("character_jump"):
            var jump_x: float = remap(variable_time, 0., variable_time_limit, 0., 1.)
            controller.jump_variable = jump_curve.sample(jump_x)
            _switch_to_jump()
            return

        # Player did not release the input
        if variable_time > variable_time_limit:
            var jump_x: float = remap(variable_time, 0., variable_time_limit, 0., 1.)
            controller.jump_variable = jump_curve.sample(jump_x)
            _switch_to_jump()
            return
        
        variable_time += delta

func _switch_to_jump() -> void:
    var next_state: ActorState = controller.get_character_state(PlayerCharacterController.CharacterStates.JUMP)
    controller.switch_state(next_state)

func exit_state() -> void:
    variable_time = 0.
    jump_pressed = false