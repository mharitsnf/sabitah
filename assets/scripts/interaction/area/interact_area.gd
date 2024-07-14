class_name InteractArea extends Area3D

@export var dialogue_resource: DialogueResource

func _ready() -> void:
	assert(dialogue_resource)
