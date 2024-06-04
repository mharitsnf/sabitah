class_name SceneManager extends Node

enum Scenes {
    GAME, MAP
}

class SceneData extends RefCounted:
    var _pscn: PackedScene
    var _instance: Node

    func _init(__pscn: PackedScene) -> void:
        _pscn = __pscn
    
    ## Returns the packed scene of this data
    func get_pscn() -> PackedScene:
        return _pscn

    func set_existing_instance(__instance: Node) -> void:
        _instance = __instance

    func create_instance() -> void:
        _instance = _pscn.instantiate()

    func get_instance() -> Node:
        return _instance

var scene_data_dict: Dictionary = {
    Scenes.GAME: SceneData.new(preload("res://assets/levels/game_container.tscn"))
}

var previous_scene_data: SceneData
var current_scene_data: SceneData

func _ready() -> void:
    _set_existing_instances()

## Helper function for setting existing instances to the [scene_data_dict].
func _set_existing_instances() -> void:
    for c: Node in get_children():
        var existing_data: Array = scene_data_dict.values().filter(func(_data: SceneData) -> bool: return _data.get_pscn().resource_path == c.scene_file_path)
        if existing_data.is_empty(): continue
        (existing_data[0] as SceneData).set_existing_instance(c)

## Helper function for removing instance to the [SceneManager].
func _instance_exit(instance: Node) -> void:
    remove_child(instance)

## Helper function for adding instance to the [SceneManager].
func _instance_enter(instance: Node) -> void:
    add_child(instance)

## Function for switching active scenes.
func switch_scene(target_scene: Scenes) -> void:
    var next_scene_data: SceneData = scene_data_dict[target_scene]
    if !next_scene_data.get_instance(): next_scene_data.create_instance()

    if current_scene_data:
        _instance_exit(current_scene_data.get_instance())
        previous_scene_data = current_scene_data

    current_scene_data = next_scene_data
    _instance_enter(next_scene_data.get_instance())