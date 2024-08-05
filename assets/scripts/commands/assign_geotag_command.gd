class_name AssignGeotagCommand extends Command

func action(args: Array = []) -> void:
	assert(args.size() == 2)

	var tag: String = args[0]
	var target: Variant = args[1]

	if target is Picture:
		target.geotag_id = tag
	elif target is Memory:
		target.geotag_id = tag
	
	# ResourceSaver.save(pic)