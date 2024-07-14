class_name QuitGameCommand extends Command

func action(_args: Array = []) -> void:
	# Uncomment if saving resources is needed.
	PictureState.save_pictures()
	ClueState.save_clues()
	
	State.tree.quit()