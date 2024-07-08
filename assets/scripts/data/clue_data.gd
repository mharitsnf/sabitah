class_name ClueData extends RefCounted

var _clue: Clue
var _clue_area: ClueArea
var _clue_menu_button: GenericButton

func _init(__clue: Clue, __clue_area: ClueArea, __clue_menu_button: GenericButton) -> void:
	_clue = __clue
	_clue_area = __clue_area
	_clue_menu_button = __clue_menu_button

func get_clue() -> Clue:
	return _clue

func get_clue_area() -> ClueArea:
	return _clue_area

func get_clue_menu_button() -> GenericButton:
	return _clue_menu_button

func _to_string() -> String:
	return "clue: " + str(_clue) + " clue_area: " + str(_clue_area)