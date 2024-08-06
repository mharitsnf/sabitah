class_name MemoryArea extends Area3D

@export var visuals_container: Node3D

var time_window: Vector2
var time_manager: TimeManager

func _ready() -> void:
	time_manager = Group.first("time_manager")
	assert(time_manager)

func _process(_delta: float) -> void:
	if time_window.x == -1 or time_window.y == -1: return

	var inside_window: bool = time_manager.time_elapsed >= time_window.x and time_manager.time_elapsed <= time_window.y
	monitorable = inside_window
	visuals_container.visible = inside_window