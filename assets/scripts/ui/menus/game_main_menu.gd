class_name GameMainMenu extends MainMenu

@export var globe_button: GenericButton
@export var help_button: GenericButton

func _ready() -> void:
	super()
	assert(globe_button)
	assert(help_button)

func set_button_visibilities() -> void:
	globe_button.visible = ProgressState.get_global_progress(['globe_menu_unlocked']) and (State.actor_im as ActorInputManager).current_actor_equals(ActorInputManager.PlayerActors.BOAT)
	help_button.visible = ProgressState.get_global_progress(['help_menu_unlocked'])
