class_name GameMainMenu extends MainMenu

@export var gallery_button: GenericButton
@export var globe_button: GenericButton
@export var adventure_booklet_button: GenericButton

func _ready() -> void:
	super()
	assert(globe_button)
	assert(adventure_booklet_button)

func set_button_visibilities() -> void:
	gallery_button.visible = ProgressState.get_global_progress(["ship_first_interaction"])
	globe_button.visible = (State.actor_im as ActorInputManager).current_actor_equals(ActorInputManager.PlayerActors.BOAT)
	adventure_booklet_button.visible = ProgressState.get_global_progress(["ship_first_interaction"])
