class_name MemoryData extends RefCounted

var _memory: Memory
var _menu_button: GenericButton
var _toggle_button: GenericToggleButton
var _area: Area3D

func _init(__memory: Memory, __menu_button: GenericButton, __toggle_button: GenericToggleButton) -> void:
	_memory = __memory
	_menu_button = __menu_button
	_toggle_button = __toggle_button

func set_area(value: Area3D) -> void:
	_area = value

func get_area() -> Area3D:
	return _area

func set_area_monitorable(value: bool) -> void:
	if _area:
		_area.monitorable = value

func get_memory() -> Memory:
	return _memory

func get_menu_button() -> GenericButton:
	return _menu_button

func get_toggle_button() -> GenericToggleButton:
	return _toggle_button