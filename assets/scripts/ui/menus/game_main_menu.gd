class_name GameMainMenu extends MainMenu

@export var globe_button: GenericButton
@export var help_button: GenericButton

func _ready() -> void:
	super()
	assert(globe_button)
	assert(help_button)

func set_button_visibilities() -> void:
	globe_button.visible = (State.actor_im as ActorInputManager).current_actor_equals(ActorInputManager.PlayerActors.BOAT)
