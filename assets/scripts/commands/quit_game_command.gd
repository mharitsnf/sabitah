class_name QuitGameCommand extends Command

func action(_args: Array = []) -> void:
	# Uncomment if saving resources is needed.
	# PictureState.save_pictures()
	# MemoryState.save_memories()
	# MemoryState.save_mental_images()

	State.tree.quit()