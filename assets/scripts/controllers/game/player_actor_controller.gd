class_name PlayerActorController extends PlayerController

func enter_controller() -> void:
	Common.InputPromptManager.add_to_hud_layer(hud_layer, [
		'RMB_Enter', 'RMB_Exit', 'LMB_Picture'
	])

	if Common.CutsceneManager.is_cutscene_running(): return

	Common.InputPromptManager.show_input_prompt([
		'RMB_Enter'
	])

func exit_controller() -> void:
	Common.InputPromptManager.remove_from_hud_layer(hud_layer, [
		'RMB_Enter', 'RMB_Exit', 'LMB_Picture'
	])