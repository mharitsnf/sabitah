class_name RemoveActiveFilterCommand extends Command

func action(args: Array = []) -> void:
	assert(args.size() == 1)

	var tag_id: String = args[0]
	var fd: FilterData = PictureState.get_filter_data(tag_id)

	PictureState.gallery_active_filters.erase(fd)
	print(PictureState.gallery_active_filters)