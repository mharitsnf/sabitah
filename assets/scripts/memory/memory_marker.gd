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
	var memory_area: Area3D = MEMORY_AREA_PSCN.instantiate()
	memory_area.monitorable = md.get_memory().locked_status == Memory.LockedStatus.LOCKED
	md.set_area(memory_area)
	add_child.call_deferred(memory_area)