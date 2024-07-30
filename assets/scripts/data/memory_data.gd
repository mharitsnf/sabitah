class_name MemoryData extends RefCounted

var _memory: Memory
var _menu_button: GenericButton

func _init(__memory: Memory, __menu_button: GenericButton) -> void:
	_memory = __memory
	_menu_button = __menu_button

func get_memory() -> Memory:
	return _memory

func get_menu_button() -> GenericButton:
	return _menu_button

## Returns the category this memory is associated to.
func get_memory_category_id() -> String:
	return _memory.category_id