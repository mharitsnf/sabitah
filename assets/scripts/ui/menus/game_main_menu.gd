class_name GameMainMenu extends MainMenu

@export var globe_button: GenericButton
@export var help_button: GenericButton

func set_button_visibilities() -> void:
	globe_button.visible = ProgressState.get_global_progress(['globe_menu_unlocked'])
	help_button.visible = ProgressState.get_global_progress(['help_menu_unlocked'])
