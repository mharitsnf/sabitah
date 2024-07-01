class_name PlayerData extends RefCounted

var _pscn: PackedScene
var _instance: Node

func _init(__pscn: PackedScene = null) -> void:
    if __pscn: _pscn = __pscn

func get_pscn() -> PackedScene:
    return _pscn

func get_instance() -> Node:
    return _instance

## Sets [_pscn] as [__pscn].
func set_pscn(__pscn: PackedScene) -> void:
    assert(__pscn)
    _pscn = __pscn

## Sets [_instance] from an existing node.
func set_instance(__instance: Node) -> void:
    assert(__instance)
    _set_instance(__instance)

## Creates a new instance from the [_pscn].
func create_instance() -> void:
    assert(_pscn)
    var tmp_instance: Node = _pscn.instantiate()
    _set_instance(tmp_instance)

## Private. Helper function for setting [_instance] and [_camera_manager].
func _set_instance(__instance: Node) -> void:
    _instance = __instance