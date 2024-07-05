class_name RemoveActiveFilterCommand extends Command

func action(args: Array = []) -> void:
	assert(args.size() == 1)

	var tag_id: String = args[0]
	var fd: FilterData = PictureState.get_filter(tag_id)

	PictureState.active_filters.erase(fd)