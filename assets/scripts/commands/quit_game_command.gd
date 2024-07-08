class_name QuitGameCommand extends Command

func action(_args: Array = []) -> void:
	PictureState.save_pictures()
	ClueState.save_clues()
	State.tree.quit()