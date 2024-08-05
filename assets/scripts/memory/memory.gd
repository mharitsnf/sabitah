class_name Memory extends Resource

enum LockedStatus {
	LOCKED, UNLOCKED
}

@export var id: String
@export_group("Owner data")
@export var memory_owner: MemoryOwner
@export_group("Memory data")
@export var title: String
@export var time_window: Vector2
@export var locked_status: LockedStatus