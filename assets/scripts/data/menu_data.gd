class_name MenuData extends RefCounted

var _key: State.UserInterfaces
var _pscn: PackedScene
var _instance: BaseMenu

func _init(__pscn: PackedScene, __key: State.UserInterfaces) -> void:
	_pscn = __pscn
	_key = __key

func get_key() -> State.UserInterfaces:
	return _key

func create_instance() -> void:
	_instance = _pscn.instantiate()

func get_instance() -> BaseMenu:
	return _instance