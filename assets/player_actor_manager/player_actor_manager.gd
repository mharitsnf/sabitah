class_name PlayerActorManager extends Node

enum PlayerActors {
    CHARACTER, BOAT
}

class PlayerData extends RefCounted:
    var _pscn: PackedScene
    var _instance: BaseActor
    var _reference_manager: PlayerReferenceManager

    func _init(__pscn: PackedScene) -> void:
        _pscn = __pscn

    func get_pscn() -> PackedScene:
        return _pscn

    func get_instance() -> BaseActor:
        return _instance

    func get_reference_manager() -> PlayerReferenceManager:
        return _reference_manager

    func set_instance(__instance: BaseActor) -> void:
        _instance = __instance
        _reference_manager = _instance.get_node("ReferenceManager")
        assert(_reference_manager)
    
    func create_instance() -> void:
        _instance = _pscn.instantiate()
        _reference_manager = _instance.get_node("ReferenceManager")
        assert(_reference_manager)

var player_data_dict: Dictionary = {
    PlayerActors.CHARACTER: PlayerData.new(preload("res://assets/prefabs/actor/player_character.tscn"))
}

var previous_player_data: PlayerData
var current_player_data: PlayerData:
    set(value):
        current_player_data = value
        if !value: return
        if main_camera:
            main_camera.follow_target = value.get_reference_manager().third_person_camera
        if ocean_data:
            ocean_data.target = value.get_instance()

var main_camera: MainCamera
var ocean_data: OceanData
var menu_layer: MenuLayer

func _ready() -> void:
    main_camera = Group.first("main_camera")
    ocean_data = Group.first("ocean_data")
    menu_layer = Group.first("menu_layer")

    _set_existing_instances()
    _remove_other_actors()
    _create_actor_instances()
    _initiate_current_player_data()

# Run the delegated player input process
func _process(delta: float) -> void:
    if !current_player_data: return
    if !current_player_data.get_instance(): return
    if menu_layer and menu_layer.has_active_menu(): return

    current_player_data.get_instance().delegated_process(delta)
    current_player_data.get_instance().player_input_process(delta)

# Run the delegated player unhandled input
func _unhandled_input(event: InputEvent) -> void:
    if !current_player_data: return
    if !current_player_data.get_instance(): return
    if menu_layer and menu_layer.has_active_menu(): return
    
    current_player_data.get_instance().player_unhandled_input(event)

# region Initialization

## Private. Register existing children as instances in the [player_data_dict].
func _set_existing_instances() -> void:
    if get_child_count() == 0: return

    var idx: int = 0
    for c: Node in get_children():
        if !(c is BaseActor): continue
        var existing_data: Array = player_data_dict.values().filter(func(_data: PlayerData) -> bool: return _data.get_pscn().resource_path == c.scene_file_path)
        if existing_data.is_empty(): continue
        (existing_data[0] as PlayerData).set_instance(c)
        
        # set the first child as current player data
        if idx == 0: current_player_data = (existing_data[0] as PlayerData)

        idx += 1

func _create_actor_instances() -> void:
    for pd: PlayerData in player_data_dict.values():
        if pd.get_instance(): continue
        pd.create_instance()

## Private. Remove children other than the first children from the scene tree.
func _remove_other_actors() -> void:
    if get_child_count() > 1:
        var children: Array[Node] = get_children()
        children.pop_front()
        for c: Node in children:
            remove_child.call_deferred(c)

func _initiate_current_player_data() -> void:
    if current_player_data: return
    if get_child_count() == 0:
        current_player_data = (player_data_dict[0] as PlayerData)
        current_player_data.get_instance().position = Vector3(0., State.Game.PLANET_RADIUS, 0.)
        add_child.call_deferred(current_player_data.get_instance())