class_name PlayerActorController extends PlayerController

func enter_controller() -> void:
	Common.InputPromptManager.add_to_hud_layer(hud_layer, [
		'RMB_Enter', 'RMB_Exit', 'LMB_Picture'
	])

	Common.InputPromptManager.show_input_prompt([
		'RMB_Enter'
	])

func exit_controller() -> void:
	Common.InputPromptManager.remove_from_hud_layer(hud_layer, [
		'RMB_Enter', 'RMB_Exit', 'LMB_Picture'
	])

func _on_follow_target_changed(new_vc: VirtualCamera) -> void:
	if (State.actor_im as ActorInputManager).get_current_controller() != self: return
	if new_vc is FirstPersonCamera:
		Common.InputPromptManager.hide_input_prompt(["RMB_Enter"])
		Common.InputPromptManager.show_input_prompt(["RMB_Exit", "LMB_Picture"])
	else:
		Common.InputPromptManager.hide_input_prompt(["RMB_Exit", "LMB_Picture"])
		Common.InputPromptManager.show_input_prompt(["RMB_Enter"])