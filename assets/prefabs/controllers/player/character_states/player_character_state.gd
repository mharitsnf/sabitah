class_name PlayerCharacterState extends ActorState

@export var actor: CharacterActor
@export var controller: PlayerCharacterController

func _ready() -> void:
    assert(actor)
    assert(controller)