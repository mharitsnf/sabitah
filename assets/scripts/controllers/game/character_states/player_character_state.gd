class_name PlayerCharacterState extends ActorState

@export_group("References")
@export var actor: CharacterActor
@export var controller: PlayerCharacterController

func _ready() -> void:
    assert(actor)
    assert(controller)

func _switch_to_jump() -> void:
    var next_state: ActorState = controller.get_character_state(PlayerCharacterController.CharacterStates.JUMP)
    controller.switch_state(next_state)