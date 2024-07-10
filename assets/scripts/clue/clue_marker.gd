class_name ClueMarker extends Marker3D

@export var clue_id: String

func _ready() -> void:
	assert(clue_id)

	var cd: ClueData = ClueState.get_clue_data_by_id(clue_id)
	assert(cd)

	var ca: ClueArea = ClueState.create_clue_area()
	cd.set_clue_area(ca)
	add_child.call_deferred(ca)
