class_name SceneManager extends Node

enum Scenes {
    GAME, GLOBE
}

class SceneData extends RefCounted:
    var _key: SceneManager.Scenes
    var _pscn: PackedScene
    var _instance: Node

    func _init(__key: SceneManager.Scenes, __pscn: PackedScene) -> void:
        _key = __key
        _pscn = __pscn
    
    ## Returns the packed scene of this data
    func get_pscn() -> PackedScene:
        return _pscn

    func get_key() -> SceneManager.Scenes:
        return _key

    func set_instance(__instance: Node) -> void:
        _instance = __instance

    func create_instance() -> void:
        _instance = _pscn.instantiate()

    func get_instance() -> Node:
        return _instance

var scene_data_dict: Dictionary = {
    Scenes.GAME: SceneData.new(Scenes.GAME, preload("res://assets/scene_containers/game_container.tscn")),
    Scenes.GLOBE: SceneData.new(Scenes.GLOBE, preload("res://assets/scene_containers/globe_container.tscn"))}

var previous_scene_data: SceneData
var current_scene_data: SceneData

func _ready() -> void:
    _set_existing_instances()

## Helper function for setting existing instances to the [scene_data_dict].
func _set_existing_instances() -> void:
    if get_child_count() == 0: return
    
    var idx: int = 0
    for child: Node in get_children():
        var existing_data: Array = scene_data_dict.values().filter(func(_data: SceneData) -> bool: return _data.get_pscn().resource_path == child.scene_file_path)
        if existing_data.is_empty(): continue
        
        (existing_data[0] as SceneData).set_instance(child)
        if idx == 0:
            current_scene_data = existing_data[0] as SceneData

        idx += 1

func get_active_scene_type() -> Scenes:
    return current_scene_data.get_key()

## Function for switching active scenes.
func switch_scene(target_scene: Scenes) -> void:
    if current_scene_data and current_scene_data.get_key() == target_scene:
        push_error("Target scene is the same as the current one!")
        return

    var next_scene_data: SceneData = scene_data_dict[target_scene]
    if !next_scene_data.get_instance(): next_scene_data.create_instance()

    if current_scene_data:
        remove_child.call_deferred(current_scene_data.get_instance())
        previous_scene_data = current_scene_data

    current_scene_data = next_scene_data
    add_child.call_deferred(next_scene_data.get_instance())