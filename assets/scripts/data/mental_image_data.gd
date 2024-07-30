class_name MentalImageData extends RefCounted

var _mental_image: MentalImage
var _menu_button: GenericButton

func _init(__mental_image: MentalImage, __menu_button: GenericButton) -> void:
	_mental_image = __mental_image
	_menu_button = __menu_button

func get_mental_image() -> MentalImage:
	return _mental_image

func get_memory_id() -> String:
	return _mental_image.memory_id