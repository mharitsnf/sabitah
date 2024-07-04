class_name StarData extends RefCounted

var _game_instance: Node
var _globe_instance: Node

func _init(__game_instance: Node, __globe_instance: Node = null) -> void:
	_game_instance = __game_instance
	_globe_instance = __globe_instance

func get_game_instance() -> Node:
	return _game_instance

func get_globe_instance() -> Node:
	return _globe_instance