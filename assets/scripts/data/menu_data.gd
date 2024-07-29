class_name MenuData extends RefCounted

var _key: String
var _pscn: PackedScene
var _instance: BaseMenu

func _init(__pscn: PackedScene, __key: String) -> void:
	_pscn = __pscn
	_key = __key

func get_key() -> String:
	return _key

func create_instance() -> void:
	_instance = _pscn.instantiate()

func get_instance() -> BaseMenu:
	return _instance