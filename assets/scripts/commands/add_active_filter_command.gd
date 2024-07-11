class_name AddActiveFilterCommand extends Command

func action(args: Array = []) -> void:
	assert(args.size() == 1)

	var tag_id: String = args[0]
	var fd: Dictionary = PictureState.get_filter(tag_id)

	PictureState.active_filters.append(fd)