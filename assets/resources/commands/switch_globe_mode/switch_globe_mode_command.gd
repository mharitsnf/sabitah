class_name SwitchGlobeModeCommand extends Command

@export var target_mode: PlayerGlobeModeManager.GlobeModes

func action(_args: Array = []) -> void:
	var target_md: PlayerGlobeModeManager.ModeData = State.pgmm.get_mode_data(target_mode)
	await State.pgmm.switch_modes(target_md)