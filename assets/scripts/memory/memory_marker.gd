class_name MemoryMarker extends Marker3D

@export var memory_id: String
@export var ghost_visuals_pscn: PackedScene

const MEMORY_AREA_PSCN: PackedScene = preload("res://assets/prefabs/memory/memory_area.tscn")

func _ready() -> void:
	assert(memory_id != "")
	assert(ghost_visuals_pscn)

	var memories: Array[MemoryData] = MemoryState.get_memories({ "id": memory_id })
	if memories.is_empty():
		push_warning("Memory id: " + memory_id + " resource not found.")
		return
	var md: MemoryData = memories[0]
	
	var memory_area: Area3D = MEMORY_AREA_PSCN.instantiate()
	var colshape: CollisionShape3D = memory_area.get_node("CollisionShape3D")
	md.set_area(memory_area)

	var visuals: Node3D = ghost_visuals_pscn.instantiate()

	add_child.call_deferred(memory_area)
	colshape.add_child.call_deferred(visuals)