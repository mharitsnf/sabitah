class_name Memory extends Resource

enum LockedStatus {
	LOCKED, UNLOCKED
}

@export var id: String
@export var owner: String
@export var title: String
@export var time_window: Vector2
@export var locked_status: LockedStatus