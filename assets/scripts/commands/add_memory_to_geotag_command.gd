class_name AddMemoryToGeotagCommand extends Command

func action(args: Array = []) -> void:
	assert(args.size() == 1)
	var memory: Memory = args[0]

	MemoryState.memories_to_be_geotagged.append(memory)
