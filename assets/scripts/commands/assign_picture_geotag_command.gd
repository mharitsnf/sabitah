class_name AssignPictureGeotagCommand extends Command

func action(args: Array = []) -> void:
	assert(args.size() == 2)

	var tag: String = args[0]
	var pic: Picture = args[1]

	pic.geotag_id = tag
	ResourceSaver.save(pic)