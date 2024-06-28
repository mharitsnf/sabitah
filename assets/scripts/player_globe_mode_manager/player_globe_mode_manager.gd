class_name PlayerGlobeModeManager extends Node

enum GlobeModes {
	NONE, ISLAND_SEARCH, ISLAND_REGISTRATION
}

class ModeData extends RefCounted:
	var _pscn: PackedScene
	var _instance: GlobeMode
	func _init(__pscn: PackedScene = null) -> void:
		if __pscn: _pscn = __pscn

	func get_pscn() -> PackedScene:
		return _pscn

	func get_instance() -> GlobeMode:
		return _instance

	func set_instance(__instance: GlobeMode) -> void:
		assert(__instance)
		_instance = __instance

	func create_instance() -> void:
		assert(_pscn)
		_instance = _pscn.instantiate()

@export var globe_mode_pscns: Dictionary = {
	GlobeModes.ISLAND_SEARCH: null,
	GlobeModes.ISLAND_REGISTRATION: null,
}

var globe_mode_dict: Dictionary = {
	GlobeModes.ISLAND_SEARCH: null,
	GlobeModes.ISLAND_REGISTRATION: null,
}

var prev_globe_mode: ModeData
var current_globe_mode: ModeData

func _enter_tree() -> void:
	State.pgmm = self

func _ready() -> void:
	_create_mode_data()
	_set_existing_instances()

func _process(delta: float) -> void:
	if !current_globe_mode: return
	if !current_globe_mode.get_instance(): return

	current_globe_mode.get_instance().delegated_process(delta)
	current_globe_mode.get_instance().player_input_process(delta)

func _physics_process(delta: float) -> void:
	if !current_globe_mode: return
	if !current_globe_mode.get_instance(): return

	current_globe_mode.get_instance().delegated_physics_process(delta)

func _unhandled_input(event: InputEvent) -> void:
	if !current_globe_mode: return
	if !current_globe_mode.get_instance(): return

	current_globe_mode.get_instance().delegated_unhandled_input(event)

func get_mode_data(type: GlobeModes) -> ModeData:
	if type == GlobeModes.NONE:
		return _create_empty_mode_data()
	
	return (globe_mode_dict[type] as ModeData)

func _create_empty_mode_data() -> ModeData:
	return ModeData.new()

func switch_modes(new_mode: ModeData) -> void:
	if new_mode == current_globe_mode:
		push_warning("new_mode is the same as current_globe_mode.")
		return

	if current_globe_mode:
		if current_globe_mode.get_instance(): await current_globe_mode.get_instance().exit_mode()
		prev_globe_mode = current_globe_mode

	current_globe_mode = new_mode
	if new_mode.get_instance(): await new_mode.get_instance().enter_mode()

## Private. Creates mode data based on the packed scenes.
func _create_mode_data() -> void:
	for k: GlobeModes in globe_mode_pscns.keys():
		if k == GlobeModes.NONE: continue
		if globe_mode_pscns[k] is PackedScene:
			globe_mode_dict[k] = ModeData.new(globe_mode_pscns[k])
		
## Private. Register existing children as instances in the [globe_mode_dict].
func _set_existing_instances() -> void:
	if get_child_count() == 0: return

	for c: Node in get_children():
		if !(c is GlobeMode): continue
		var existing_data: Array = globe_mode_dict.values().filter(func(_data: ModeData) -> bool:
			return _data.get_pscn().resource_path == c.scene_file_path
		)
		if existing_data.is_empty(): continue
		(existing_data[0] as ModeData).set_instance(c)
