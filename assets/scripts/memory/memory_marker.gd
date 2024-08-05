class_name MemoryMarker extends Marker3D

@export var memory_id: String

const MEMORY_AREA_PSCN: PackedScene = preload("res://assets/prefabs/memory/memory_area.tscn")

func _ready() -> void:
	assert(memory_id != "")

	var memories: Array[MemoryData] = MemoryState.get_memories({ "id": memory_id })
	if memories.is_empty():
		push_warning("Memory id: " + memory_id + " resource not found.")
		return
	var md: MemoryData = memories[0]
	
	var memory_area: MemoryArea = MEMORY_AREA_PSCN.instantiate()
	var visual_container: Node3D = memory_area.visuals_container
	md.set_area(memory_area)

	var visuals: Node3D = md.get_memory().memory_owner.ghost_visuals_pscn.instantiate()

	add_child.call_deferred(memory_area)
	visual_container.add_child.call_deferred(visuals)