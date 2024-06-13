class_name MainCamera extends Camera3D

class FollowData extends RefCounted:
	var _main_camera: MainCamera
	var _target: VirtualCamera
	var _camera_target: Node3D
	var _rt: RemoteTransform3D
	
	func _init(__main_camera: MainCamera, __target: VirtualCamera) -> void:
		_main_camera = __main_camera
		_target = __target
		_camera_target = _target.camera_target

		# Creates a new remote transform
		var rt_builder: Common.RemoteTransform3DBuilder = Common.RemoteTransform3DBuilder.new()
		rt_builder.rename(_main_camera.name)
		rt_builder.update_rotation(!_target.camera_adjusting_basis)
		_rt = rt_builder.get_remote_transform()
	
	# Connect the [_target]'s adjusting basis changed signal to the main camera.
	func _connect_adjusting_basis() -> void:
		if !_target.camera_adjusting_basis_changed.is_connected(_on_camera_adjusting_basis_changed):
			_target.camera_adjusting_basis_changed.connect(_on_camera_adjusting_basis_changed)
	
	## Disconnect the [_target]'s adjusting basis changed signal to the main camera.
	func _disconnect_adjusting_basis() -> void:
		if _target.camera_adjusting_basis_changed.is_connected(_on_camera_adjusting_basis_changed):
			_target.camera_adjusting_basis_changed.disconnect(_on_camera_adjusting_basis_changed)

	## Listener for the [_target]'s signal [camera_adjusting_basis_changed].
	func _on_camera_adjusting_basis_changed(value: bool) -> void:
		_rt.update_rotation = !value

	## Adds the remote transform [_rt] to the camera target [_camera_target].
	func mount_remote_transform() -> void:
		_connect_adjusting_basis()
		if !_rt.is_inside_tree():
			_camera_target.add_child(_rt)

	## Removes the remote transform [_rt] child of the [_target].
	func dismount_remote_transform() -> void:
		_disconnect_adjusting_basis()
		if _rt.is_inside_tree() and _rt.get_parent() == _camera_target:
			_camera_target.remove_child(_rt)

	## Returns the current virtual camera, [_target].
	func get_target() -> VirtualCamera:
		return _target
	
	## Returns the current camera target of the virtual camera, [_camera_target]
	func get_camera_target() -> Node3D:
		return _camera_target

	## Returns the remote transform attached to [_target].
	func get_remote_transform() -> RemoteTransform3D:
		return _rt
	
	## Sets the remote path of the [_rt] node.
	func set_remote_path(new_path: NodePath) -> void:
		_rt.remote_path = new_path

@export_group("Following")
## Which [VirtualCamera] should this [MainCamera] follow?
@export var follow_target: VirtualCamera:
	# This function is first called before the main camera enters the scene tree.
	# Meaning, the change follow target will not work immediately because the path does not exist yet.
	set = _set_follow_target

var transitioning: bool = false
var transition_elapsed_time: float = 0.
signal transition_finished

var previous_follow_data: FollowData
var current_follow_data: FollowData

# region Built-in functions

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(delta: float) -> void:
	_transition(delta)

	if current_follow_data:
		if !transitioning: fov = current_follow_data.get_target().get_fov()
		current_follow_data.get_target().delegated_process(delta)

# region Follow target functions

## Sets a new follow target for the camera.
func _set_follow_target(new_target: VirtualCamera) -> void:
	if !new_target:
		push_error("Unable to set null as the follow target.")
		return
	if follow_target == new_target:
		push_warning("The current follow target is the same as the new one.")
		return
	if transitioning:
		push_warning("Main camera is still transitioning")
		return
	
	follow_target = new_target
	_change_follow_target(new_target)

## Executes the change follow target transition sequence.
func _change_follow_target(value: VirtualCamera) -> void:
	# During first initialization (before entering scene tree), wait for the main camera
	# to enter the scene tree first.
	if !is_inside_tree(): await tree_entered

	# Clears the remote path of the current remote transform, if we have any
	if current_follow_data:
		current_follow_data.set_remote_path(NodePath(""))
		previous_follow_data = current_follow_data
	
	# Creates a new follow data for the new follow target and mount the remote transform
	current_follow_data = FollowData.new(self, value)
	current_follow_data.mount_remote_transform()

	# Start transition if [use_transition] is true
	if value.camera_use_transition:
		transitioning = true
		await transition_finished

	# Dismount the previous remote transform
	if previous_follow_data:
		previous_follow_data.dismount_remote_transform()
	
	# Assigns the new remote transform to the new path
	current_follow_data.set_remote_path(get_path())

# region Transition functions

func _transition_finished() -> void:
	transitioning = false
	transition_elapsed_time = 0.

func _transition(delta: float) -> void:
	if transitioning:
		if !previous_follow_data or !current_follow_data or transition_elapsed_time > current_follow_data.get_target().camera_tween_settings.tween_duration:
			transition_finished.emit()
			return

		global_position = Tween.interpolate_value(
			previous_follow_data.get_remote_transform().global_position,
			current_follow_data.get_remote_transform().global_position - previous_follow_data.get_remote_transform().global_position,
			transition_elapsed_time,
			current_follow_data.get_target().camera_tween_settings.tween_duration,
			current_follow_data.get_target().camera_tween_settings.tween_trans,
			current_follow_data.get_target().camera_tween_settings.tween_ease
		)

		var previous_quat: Quaternion = Quaternion(previous_follow_data.get_remote_transform().global_basis.orthonormalized())
		var current_quat: Quaternion = Quaternion(current_follow_data.get_remote_transform().global_basis.orthonormalized())
		quaternion = Tween.interpolate_value(
			previous_quat,
			previous_quat.inverse() * current_quat,
			transition_elapsed_time,
			current_follow_data.get_target().camera_tween_settings.tween_duration,
			current_follow_data.get_target().camera_tween_settings.tween_trans,
			current_follow_data.get_target().camera_tween_settings.tween_ease
		)

		fov = Tween.interpolate_value(
			previous_follow_data.get_target().get_fov(),
			current_follow_data.get_target().get_fov() - previous_follow_data.get_target().get_fov(),
			transition_elapsed_time,
			current_follow_data.get_target().camera_tween_settings.tween_duration,
			current_follow_data.get_target().camera_tween_settings.tween_trans,
			current_follow_data.get_target().camera_tween_settings.tween_ease
		)

		transition_elapsed_time += delta