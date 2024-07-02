class_name AssignPictureGeotagCommand extends Command

func action(args: Array = []) -> void:
	assert(args.size() == 2)

	var _tag: String = args[0]
	var _pic: Picture = args[1]

	# State.assign_picture_tag(pic, tag)