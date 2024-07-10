class_name CollectibleData extends RefCounted

var _collectible: Collectible
var _menu_button: GenericButton

func _init(__collectible: Collectible, __menu_button: GenericButton) -> void:
	_collectible = __collectible
	_menu_button = __menu_button

func get_collectible() -> Collectible:
	return _collectible

func get_menu_button() -> GenericButton:
	return _menu_button