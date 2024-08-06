@tool
class_name Memory extends Resource

enum LockedStatus {
	LOCKED, UNLOCKED
}

@export var id: String
@export_group("Owner data")
@export var memory_owner: MemoryOwner
@export_group("Memory data")
@export var title: String
@export var geotag_id: String = "none"
@export var time_window: Vector2 = Vector2(-1, -1): set = _set_time_window
@export var locked_status: LockedStatus

func _set_time_window(value: Vector2) -> void:
	if value.y < value.x:
		push_error("Memory Resource: Y cannot be smaller than X.")
		return
	
	time_window = value