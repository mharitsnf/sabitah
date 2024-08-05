class_name ApplyMemoryToGeotagCommand extends Command

func action(args: Array = []) -> void:
	assert(args.size() == 1)
	var new_geotag_id: String = args[0]

	for memory: Memory in MemoryState.memories_to_be_geotagged:
		memory.geotag_id = new_geotag_id
	
	var menu_layer: MenuLayer = Group.first("menu_layer")
	await (menu_layer as MenuLayer).back()
