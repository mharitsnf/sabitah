class_name MemoryMarker extends Marker3D

@export var memory_id: String

const MEMORY_AREA_PSCN: PackedScene = preload("res://assets/prefabs/memory/memory_area.tscn")

func _ready() -> void:
	assert(memory_id != "")

	# Get the associated memory data
	var memories: Array[MemoryData] = MemoryState.get_memories({ "id": memory_id })
	if memories.is_empty():
		push_warning("Memory id: " + memory_id + " resource not found.")
		return
	var md: MemoryData = memories[0]
	
	# Create a new memory area
	var memory_area: MemoryArea = MEMORY_AREA_PSCN.instantiate()
	memory_area.time_window = md.get_memory().time_window
	md.set_area(memory_area)

	# Add memory area to the marker (self)
	add_child.call_deferred(memory_area)

	# Add visuals to the area
	var visuals: Node3D = md.get_memory().memory_owner.ghost_visuals_pscn.instantiate()
	var visual_container: Node3D = memory_area.visuals_container
	visual_container.add_child.call_deferred(visuals)