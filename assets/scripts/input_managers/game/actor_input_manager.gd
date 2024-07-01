class_name ActorInputManager extends InputManager

# region Enums

enum PlayerActors {
	CHARACTER, BOAT, SUNDIAL
}

enum LightType {
	NORMAL, SUNDIAL
}

@export var player_actor_pscns: Dictionary = {
	PlayerActors.BOAT: null,
	PlayerActors.CHARACTER: null,
}

# region References

var current_light_type: LightType = LightType.NORMAL: set = _set_current_light_type

var main_camera: MainCamera
var ocean_data: OceanData

# region Entry functions

func _enter_tree() -> void:
	State.actor_im = self

func _ready() -> void:
	super()
	_create_actor_instances()
	_init_current_player_data()

func _setup_references() -> void:
	super()
	main_camera = Group.first("main_camera")
	assert(main_camera)
	ocean_data = Group.first("ocean_data")
	assert(ocean_data)

func _create_player_data() -> void:
	for k: PlayerActors in player_actor_pscns.keys():
		if player_actor_pscns[k] is PackedScene:
			data_dict[k] = ActorData.new(player_actor_pscns[k])

func _set_existing_instances() -> void:
	if get_child_count() == 0: return

	for c: Node in get_children():
		if !(c is BaseActor): continue
		var existing_data: Array = data_dict.values().filter(func(_data: ActorData) -> bool:
			return _data.get_pscn().resource_path == c.scene_file_path
		)
		if existing_data.is_empty(): continue
		(existing_data[0] as ActorData).set_instance(c)

## Private. Create actor instances.
func _create_actor_instances() -> void:
	for pd: ActorData in data_dict.values():
		if pd.get_instance(): continue
		pd.create_instance()

## Private. Assign a default PlayerData to the current one.
func _init_current_player_data() -> void:
	if get_child_count() == 0:
		# Initialize the boat on a specific location
		add_child.call_deferred((data_dict[PlayerActors.BOAT] as ActorData).get_instance())
		await (data_dict[PlayerActors.BOAT] as ActorData).get_instance().tree_entered
		(data_dict[PlayerActors.BOAT] as ActorData).get_instance().global_position = Vector3(0., State.PLANET_RADIUS, 0.)

	switch_data(data_dict[PlayerActors.BOAT] as ActorData)

# region Data switching function

func switch_data(new_data: PlayerData) -> Array:
	if transitioning:
		push_error("ActorInputManager is transitioning")
		return [false]

	if !new_data:
		push_error("New player data cannot be null!")
		return [false]

	transitioning = true

	# if we have a current player data, move it to previous
	if current_data:
		current_data.get_controller().exit_controller()
		previous_data = current_data

	# Set current_data as null
	current_data = new_data
	current_data.get_controller().enter_controller()
	
	# Update the current game light status
	if new_data.get_instance() is SundialManager:
		current_light_type = LightType.SUNDIAL
	else:
		current_light_type = LightType.NORMAL

	# Switch to the new actor's entry camera
	var entry_cam: VirtualCamera = new_data.get_camera_manager().get_entry_camera()
	main_camera.follow_target = entry_cam
	new_data.get_camera_manager().set_current_camera(entry_cam)

	# Make ocean switch to follow the new actor if the new instance is a base actor.
	if new_data.get_instance() is BaseActor:
		ocean_data.target = new_data.get_instance()

	# Wait for all transition to be finished
	await main_camera.transition_finished
	transitioning = false

	current_data_changed.emit()

	return [true, previous_data]

# region Input checking function

func _input_allowed() -> bool:
	if !super(): return false
	if !(current_data as ActorData).get_controller():
		push_warning("current_data has no controller!")
		return false
	return true

# region Lifecycle functions

# Run the delegated player input process
func _process(delta: float) -> void:
	if !_input_allowed(): return

	_get_switch_camera_input()

	(current_data as ActorData).get_controller().delegated_process(delta)
	(current_data as ActorData).get_controller().player_input_process(delta)

# Run the delegated player unhandled input
func _unhandled_input(event: InputEvent) -> void:
	if !_input_allowed(): return
	
	(current_data as ActorData).get_controller().player_unhandled_input(event)

# region Inputs

## Private. Switches to another camera.
func _get_switch_camera_input() -> void:
	if Input.is_action_just_pressed("switch_camera"):
		if main_camera.transitioning:
			push_warning("Main camera is still transitioning!")
			return

		var next_cam: VirtualCamera = (current_data as ActorData).get_camera_manager().get_next_camera()
		main_camera.follow_target = next_cam
		(current_data as ActorData).get_camera_manager().set_current_camera(next_cam)

# region Setters and getters

func get_current_controller() -> PlayerController:
	return (current_data as ActorData).get_controller()

## Returns the player data of the specified [key].
func get_player_data(key: PlayerActors) -> ActorData:
	return data_dict[key]

## Private. Setter for current light type.
func _set_current_light_type(value: LightType) -> void:
	current_light_type = value

	for light: Node in Group.all("game_light"):
		if light.has_method("start_shadow_transition"):
			(light as SunMoonLight).start_shadow_transition(value)
