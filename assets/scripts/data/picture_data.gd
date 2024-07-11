class_name PictureData extends RefCounted

var _pic: Picture
var _button: GenericButton
var _toggle_button: PictureToggleButton

func _init(__pic: Picture, __button: GenericButton, __toggle_button: PictureToggleButton) -> void:
	_pic = __pic
	_button = __button
	_toggle_button = __toggle_button

func set_picture_button(value: GenericButton) -> void:
	_button = value

func get_picture() -> Picture:
	return _pic

func get_picture_button() -> GenericButton:
	return _button

func get_picture_toggle_button() -> PictureToggleButton:
	return _toggle_button