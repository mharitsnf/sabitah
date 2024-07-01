class_name ActorData extends PlayerData

var _camera_manager: PlayerCameraManager
var _player_controller: PlayerController

func get_controller() -> PlayerController:
		return _player_controller

func get_camera_manager() -> PlayerCameraManager:
	return _camera_manager

## Sets [_instance] from an existing node.
func set_instance(__instance: Node) -> void:
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
func _set_instance(__instance: Node) -> void:
	super(__instance)
	_camera_manager = _instance.get_node("CameraManager")
	_player_controller = _instance.get_node("Controller")