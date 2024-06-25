class_name PlayerActorManager extends Node

enum PlayerActors {
	CHARACTER, BOAT, SUNDIAL
}

enum LightType {
	NORMAL, SUNDIAL
}

class PlayerData extends RefCounted:
	var _pscn: PackedScene
	var _instance: Node3D
	var _camera_manager: PlayerCameraManager
	var _player_controller: PlayerController

	func _init(__pscn: PackedScene = null) -> void:
		if __pscn: _pscn = __pscn

	func get_pscn() -> PackedScene:
		return _pscn

	func get_instance() -> Node3D:
		return _instance

	func get_controller() -> PlayerController:
		return _player_controller

	func get_camera_manager() -> PlayerCameraManager:
		return _camera_manager

	func set_pscn(__pscn: PackedScene) -> void:
		_pscn = __pscn

	## Sets [_instance] from an existing node.
	func set_instance(__instance: Node3D) -> void:
		assert(__instance)
		assert(__instance.has_node("CameraManager"))
		assert(__instance.has_node("Controller"))

		_set_instance(__instance)
	
	## Creates a new instance from the [_pscn].
	func create_instance() -> void:
		assert(_pscn)

		var tmp_instance: Node3D = _pscn.instantiate()
		assert(tmp_instance.has_node("CameraManager"))
		assert(tmp_instance.has_node("Controller"))

		_set_instance(tmp_instance)

	## Private. Helper function for setting [_instance] and [_camera_manager].
	func _set_instance(__instance: Node3D) -> void:
		_instance = __instance
		_camera_manager = _instance.get_node("CameraManager")
		_player_controller = _instance.get_node("Controller")

@export var player_actor_pscns: Dictionary = {
	PlayerActors.BOAT: null,
	PlayerActors.CHARACTER: null,
}

var player_data_dict: Dictionary = {
	PlayerActors.BOAT: null,
	PlayerActors.CHARACTER: null,
}

var previous_player_data: PlayerData
var current_player_data: PlayerData

var current_light_type: LightType = LightType.NORMAL: set = _set_current_light_type

var transitioning: bool = false

var main_camera: MainCamera
var ocean_data: OceanData
var menu_layer: MenuLayer

signal current_player_data_changed()

func _enter_tree() -> void:
	State.game_pam = self

func _ready() -> void:
	main_camera = Group.first("main_camera")
	ocean_data = Group.first("ocean_data")
	menu_layer = Group.first("menu_layer")

	assert(main_camera)
	assert(ocean_data)
	assert(menu_layer)

	_create_player_data()
	_set_existing_instances()
	_create_actor_instances()
	_initiate_current_player_data()

# Run the delegated player input process
func _process(delta: float) -> void:
	if !current_player_data: return
	if !current_player_data.get_instance(): return
	if !current_player_data.get_controller(): return
	if menu_layer and menu_layer.has_active_menu(): return

	_get_switch_camera_input()

	current_player_data.get_controller().delegated_process(delta)
	current_player_data.get_controller().player_input_process(delta)

# Run the delegated player unhandled input
func _unhandled_input(event: InputEvent) -> void:
	if !current_player_data: return
	if !current_player_data.get_instance(): return
	if !current_player_data.get_controller(): return
	if menu_layer and menu_layer.has_active_menu(): return
	
	current_player_data.get_controller().player_unhandled_input(event)

# region Inputs

## Private. Switches to another camera.
func _get_switch_camera_input() -> void:
	if Input.is_action_just_pressed("switch_camera"):
		if main_camera.transitioning:
			push_warning("Main camera is still transitioning!")
			return

		var next_cam: VirtualCamera = current_player_data.get_camera_manager().get_next_camera()
		main_camera.follow_target = next_cam
		current_player_data.get_camera_manager().set_current_camera(next_cam)

# region Setters and getters

## Returns the player data of the specified [key].
func get_player_data(key: PlayerActors) -> PlayerData:
	return player_data_dict[key]

# region Switching actor

## Changes to a new player data. Returns the previous player data.
func change_player_data(new_pd: PlayerData) -> Array:
	if !new_pd:
		push_error("change_player_data: new player data cannot be null!")
		return [false]

	transitioning = true

	# if we have a current player data, move it to previous
	if current_player_data:
		current_player_data.get_controller().exit_controller()
		previous_player_data = current_player_data

	# Set current_player_data as null
	current_player_data = new_pd
	current_player_data.get_controller().enter_controller()
	
	# Update the current game light status
	if new_pd.get_instance() is SundialManager:
		current_light_type = LightType.SUNDIAL
	else:
		current_light_type = LightType.NORMAL

	# Switch to the new actor's entry camera
	var entry_cam: VirtualCamera = new_pd.get_camera_manager().get_entry_camera()
	main_camera.follow_target = entry_cam
	new_pd.get_camera_manager().set_current_camera(entry_cam)

	# Make ocean switch to follow the new actor if the new instance is a base actor.
	if new_pd.get_instance() is BaseActor:
		ocean_data.target = new_pd.get_instance()

	# Wait for all transition to be finished
	await main_camera.transition_finished
	transitioning = false

	current_player_data_changed.emit()

	return [true, previous_player_data]

func _set_current_light_type(value: LightType) -> void:
	current_light_type = value

	for light: Node in Group.all("game_light"):
		if light.has_method("start_shadow_transition"):
			(light as SunMoonLight).start_shadow_transition(value)

# region Initialization

func _create_player_data() -> void:
	for k: PlayerActors in player_actor_pscns.keys():
		if player_actor_pscns[k] is PackedScene:
			player_data_dict[k] = PlayerData.new(player_actor_pscns[k])

## Private. Register existing children as instances in the [player_data_dict].
func _set_existing_instances() -> void:
	if get_child_count() == 0: return

	var idx: int = 0
	for c: Node in get_children():
		if !(c is BaseActor): continue
		var existing_data: Array = player_data_dict.values().filter(func(_data: PlayerData) -> bool:
			return _data.get_pscn().resource_path == c.scene_file_path
		)
		if existing_data.is_empty(): continue
		(existing_data[0] as PlayerData).set_instance(c)

		# set the first child as current player data
		if idx == 0: change_player_data((existing_data[0] as PlayerData))

		idx += 1

func _create_actor_instances() -> void:
	for pd: PlayerData in player_data_dict.values():
		if pd.get_instance(): continue
		pd.create_instance()

func _initiate_current_player_data() -> void:
	if current_player_data: return
	if get_child_count() == 0:
		add_child.call_deferred((player_data_dict[PlayerActors.BOAT] as PlayerData).get_instance())
		await (player_data_dict[PlayerActors.BOAT] as PlayerData).get_instance().tree_entered
		(player_data_dict[PlayerActors.BOAT] as PlayerData).get_instance().global_position = Vector3(0., State.PLANET_RADIUS, 0.)
		change_player_data(player_data_dict[PlayerActors.BOAT] as PlayerData)
