class_name GlobeInputManager extends InputManager

enum GlobeModes {
	NONE, ISLAND_SEARCH, ISLAND_REGISTRATION
}

@export var globe_mode_pscns: Dictionary = {
	GlobeModes.ISLAND_SEARCH: null,
	GlobeModes.ISLAND_REGISTRATION: null,
}

# region Entry functions

func _enter_tree() -> void:
	State.globe_im = self

func _create_player_data() -> void:
	for k: GlobeModes in globe_mode_pscns.keys():
		if globe_mode_pscns[k] is PackedScene:
			data_dict[k] = PlayerData.new(globe_mode_pscns[k])

func _set_existing_instances() -> void:
	if get_child_count() == 0: return

	for c: Node in get_children():
		if !(c is GlobeMode): continue
		var existing_data: Array = data_dict.values().filter(func(_data: PlayerData) -> bool:
			return _data.get_pscn().resource_path == c.scene_file_path
		)
		if existing_data.is_empty(): continue
		(existing_data[0] as PlayerData).set_instance(c)

# region Lifecycle functions

func _input_allowed() -> bool:
	if !super(): return false
	if !current_data.get_instance() is GlobeMode: return false
	return true

func _process(delta: float) -> void:
	if !_input_allowed(): return

	(current_data.get_instance() as GlobeMode).delegated_process(delta)
	(current_data.get_instance() as GlobeMode).player_input_process(delta)

func _physics_process(delta: float) -> void:
	if !_input_allowed(): return

	(current_data.get_instance() as GlobeMode).delegated_physics_process(delta)

func _unhandled_input(event: InputEvent) -> void:
	if !_input_allowed(): return

	(current_data.get_instance() as GlobeMode).player_unhandled_input(event)

# region Data switching function

func switch_data(new_data: PlayerData) -> Array:
	if new_data == current_data:
		push_warning("new_mode is the same as current_data.")
		return [false]

	if !new_data:
		push_error("new_data cannot be null!")
		return [false]

	if current_data:
		if current_data.get_instance(): await (current_data.get_instance() as GlobeMode).exit_controller()
		previous_data = current_data

	current_data = new_data
	if new_data.get_instance(): await (current_data.get_instance() as GlobeMode).enter_controller()
	return [true, previous_data]

# region Setters and getters

func get_mode_data(type: GlobeModes) -> PlayerData:
	if type == GlobeModes.NONE: return _create_empty_player_data()
	return (data_dict[type] as PlayerData)

func _create_empty_player_data() -> PlayerData:
	return PlayerData.new()
