class_name ApplyPicturesToGeotagCommand extends Command

func action(args: Array = []) -> void:
	assert(args.size() == 1)
	var new_geotag_id: String = args[0]

	for pic: Picture in PictureState.pictures_to_be_geotagged:
		pic.geotag_id = new_geotag_id
		ResourceSaver.save(pic)
	
	var menu_layer: MenuLayer = Group.first("menu_layer")
	await (menu_layer as MenuLayer).back()
