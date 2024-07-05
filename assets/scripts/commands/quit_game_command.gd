class_name QuitGameCommand extends Command

func action(_args: Array = []) -> void:
	PictureState.save_pictures()
	State.tree.quit()