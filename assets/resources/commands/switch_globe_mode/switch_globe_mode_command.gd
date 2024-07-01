class_name SwitchGlobeModeCommand extends Command

@export var target_mode: GlobeInputManager.GlobeModes

func action(_args: Array = []) -> void:
	var target_md: PlayerData = (State.globe_im as GlobeInputManager).get_mode_data(target_mode)
	await (State.globe_im as GlobeInputManager).switch_data(target_md)