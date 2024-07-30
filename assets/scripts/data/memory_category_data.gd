class_name MemoryCategoryData extends RefCounted

var _memory_category: MemoryCategory
var _menu_button: GenericButton

func _init(__memory_category: MemoryCategory, __menu_button: GenericButton) -> void:
	_memory_category = __memory_category
	_menu_button = __menu_button

func get_memory_category() -> MemoryCategory:
	return _memory_category

func get_menu_button() -> GenericButton:
	return _menu_button