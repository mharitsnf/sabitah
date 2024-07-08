class_name Clue extends Resource

@export var id: String = ""
@export var title: String = "Clue Title"
@export var status: ClueState.ClueStatus
@export_multiline var description: String
@export var destination: Vector3 = Vector3.ZERO
@export var reward_id: String = ""

func _to_string() -> String:
	return "[id: " + id + ", status: " + str(status) + "]"