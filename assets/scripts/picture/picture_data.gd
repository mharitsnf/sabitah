class_name PictureData extends RefCounted

var _pic: Picture
var _button: PictureButton

func _init(__pic: Picture, __button: PictureButton) -> void:
	_pic = __pic
	_button = __button

func set_picture_button(value: PictureButton) -> void:
	_button = value

func get_picture() -> Picture:
	return _pic

func get_picture_button() -> PictureButton:
	return _button