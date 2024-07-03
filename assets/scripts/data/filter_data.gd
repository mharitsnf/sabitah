class_name FilterData extends RefCounted

var _geotag_id: String
var _button: GenericToggleButton

func _init(__geotag_id: String, __button: GenericToggleButton = null) -> void:
	_geotag_id = __geotag_id
	_button = __button

func get_geotag_id() -> String:
	return _geotag_id

func get_button() -> GenericToggleButton:
	return _button

func set_button(value: GenericToggleButton) -> void:
	_button = value

func _to_string() -> String:
	return "id: " + _geotag_id + " button: " + str(_button)