class_name ClueArea extends Area3D

var data: Dictionary = {}

func _ready() -> void:
	assert(data.has("global_position"))

	global_position = data['global_position']