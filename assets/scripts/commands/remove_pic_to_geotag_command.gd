class_name RemovePictureToGeotagCommand extends Command

func action(args: Array = []) -> void:
	assert(args.size() == 1)
	var pic: Picture = args[0]

	PictureState.pictures_to_be_geotagged.erase(pic)