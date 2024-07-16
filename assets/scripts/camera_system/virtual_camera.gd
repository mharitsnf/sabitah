class_name VirtualCamera extends Node3D

class FollowData extends RefCounted:
	var _target: Node3D
	var _rt: RemoteTransform3D
	
	func _init(__target: Node3D, __rt: RemoteTransform3D) -> void:
		_target = __target
		_rt = __rt
	
	## Mount the remote transform [_rt] to the target [_target].
	func mount_remote_transform() -> void:
		_target.add_child.call_deferred(_rt)

	## Removes the remote transform [_rt] child of the [_target].
	func dismount_remote_transform() -> void:
		_target.remove_child.call_deferred(_rt)

	## Returns the current follow target, [_target].
	func get_target() -> Node3D:
		return _target
	
	## Returns the remote transform attached to [_target].
	func get_remote_transform() -> RemoteTransform3D:
		return _rt

	## Sets the remote path of the [_rt] node.
	func set_remote_path(new_path: NodePath) -> void:
		_rt.remote_path = new_path

	## Updates the [update_rotation] property inside the [RemoteTransform3D] node.
	func set_update_rotation(value: bool) -> void:
		_rt.update_rotation = value

@export_group("Main Camera")
## Which node of this [VirtualCamera] should the [MainCamera] follow?
@export var camera_target: Node3D
## Should the [MainCamera] adjust its basis to normal?
@export var camera_adjusting_basis: bool = true:
	set(value):
		camera_adjusting_basis = value
		camera_adjusting_basis_changed.emit(value)
## Should the [MainCamera] use transition when entering this [VirtualCamera]?
@export var camera_use_transition: bool = true
## Tween settings if the [camera_use_transition] is true.
@export var camera_tween_settings: TweenSettings

@export_group("Input")
## If true, the player is able to control this camera (e.g., rotate with mouse and/or joypad).
@export var allow_player_input: bool = true
## Settings for rotation inputs.
@export var rotation_settings: CameraRotationSettings

@export_group("FoV")
@export var allow_zoom: bool = false
@export var fov_tween_settings: TweenSettings
@export var fov_settings: CameraFoVSettings:
	set(value):
		fov_settings = value
		actual_fov = value.initial_fov
		_fov_input = value.initial_fov
var actual_fov: float

@export_group("Rotation")
## If true, make this camera update its basis relative to the planet surface.
## If this camera is parented to a node that has already been adjusting its basis,
## activating this property would cancel its effect.
@export var adjusting_basis: bool = true:
	set(value):
		adjusting_basis = value
		if current_follow_data: current_follow_data.set_update_rotation(!value)
@export var y_rot_target: Node3D
@export var x_rot_target: Node3D
@export var clamp_settings: CameraClampSettings

@export_group("Following")
## Who is this [VirtualCamera] currently following?
@export var follow_target: Node3D:
	# This function is first called before the main camera enters the scene tree.
	# Meaning, the change follow target will not work immediately because the path does not exist yet.
	set = _set_follow_target

## If true, then the camera will transition between different follow targets.
@export var use_transition: bool = true 
@export var tween_settings: TweenSettings
var transitioning: bool = false
var transition_elapsed_time: float = 0.
signal transition_finished

var previous_follow_data: FollowData
var current_follow_data: FollowData

var menu_layer: MenuLayer
var hud_layer: HUDLayer

signal camera_adjusting_basis_changed(new_value: bool)

# region Per-frame functions

func _ready() -> void:
	menu_layer = Group.first("menu_layer")
	hud_layer = Group.first("hud_layer")

func _process(delta: float) -> void:
	_transition(delta)
	_update_basis()

	# FoV functions
	_on_stop_smooth_fov_input()
	_clamp_fov()

	# Rotation functions
	if Common.InputState.is_keyboard_active():
		_on_stopped_smooth_rotation_input()
	
	_clamp_rotation()
	_rotate_camera()

## **Private**. Update the basis according to the normal (if [adjusting_basis] is [true]).
func _update_basis() -> void:
	if adjusting_basis: quaternion = Common.Geometry.recalculate_quaternion(basis, global_position.normalized())

# region Input and Passed functions

## Helper function to check if player input is allowed in this [VirtualCamera]
func _is_player_input_allowed() -> bool:
	# Disable input (return false) if...
	if !allow_player_input: return false
	if menu_layer and menu_layer.has_active_menu(): return false
	return true

## Delegated process to be run from the [MainCamera]
func delegated_process(_delta: float) -> void:
	pass

## Delegated process specifically for player input (joypad)
func player_input_process(_delta: float) -> void:
	if !_is_player_input_allowed(): return
	
	_rotate_joypad()

## Delegated process specifically for player input (mouse)
func player_unhandled_input(event: InputEvent) -> void:
	if !_is_player_input_allowed(): return

	if event is InputEventMouseButton:
		_zoom_mouse(event)

	if event is InputEventMouseMotion:
		_rotate_mouse(event)

# region Follow Target Functions

## Add a remote transform to the VirtualCamera's camera_target.
func mount_remote_transform(rt: RemoteTransform3D) -> void:
	if !rt.is_inside_tree():
		camera_target.add_child.call_deferred(rt)

## Remove a remote transform to the VirtualCamera's camera_target.
func unmount_remote_transform(rt: RemoteTransform3D) -> void:
	if rt.is_inside_tree() and rt.get_parent() == camera_target:
		camera_target.remove_child.call_deferred(rt)

## Sets a new follow target for the camera.
func _set_follow_target(new_target: Node3D) -> void:
	if !new_target:
		push_error("Unable to set null as the follow target.")
		return
	if follow_target == new_target:
		push_warning("The current follow target is the same as the new one.")
		return
	if transitioning:
		push_warning("Virtual camera is still transitioning")
		return
	
	follow_target = new_target
	_change_follow_target(new_target)

## Executes the change follow target transition sequence.
func _change_follow_target(value: Node3D) -> void:
	# During first initialization (before entering scene tree), wait for the main camera
	# to enter the scene tree first.
	if !is_inside_tree(): await tree_entered
	
	# Creates a new remote transform
	var rt_builder: Common.RemoteTransform3DBuilder = Common.RemoteTransform3DBuilder.new()
	rt_builder.rename(name)
	rt_builder.update_rotation(!adjusting_basis)
	var rt: RemoteTransform3D = rt_builder.get_remote_transform()
	
	# Dismisses the current follow data
	if current_follow_data:
		current_follow_data.set_remote_path(NodePath(""))
		previous_follow_data = current_follow_data
	
	# Creates a new follow data for the new follow target
	current_follow_data = FollowData.new(value, rt)
	current_follow_data.mount_remote_transform()

	# Start transition if [use_transition] is true
	if use_transition:
		transitioning = true
		await transition_finished
	
	# Dismount the previous remote transform
	if previous_follow_data:
		previous_follow_data.dismount_remote_transform()

	# Assigns the new remote transform to the new path
	current_follow_data.set_remote_path(get_path())

# region Transition functions

func _tween_fov(target_fov: float) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "actual_fov", target_fov, fov_tween_settings.tween_duration).set_ease(fov_tween_settings.tween_ease).set_trans(fov_tween_settings.tween_trans)
	await tween.finished

func _transition_finished() -> void:
	transitioning = false
	transition_elapsed_time = 0.

func _transition(delta: float) -> void:
	if transitioning:
		if !previous_follow_data or !current_follow_data or transition_elapsed_time > tween_settings.tween_duration:
			transition_finished.emit()
			return

		global_position = Tween.interpolate_value(
			previous_follow_data.get_remote_transform().global_position,
			current_follow_data.get_remote_transform().global_position - previous_follow_data.get_remote_transform().global_position,
			transition_elapsed_time,
			camera_tween_settings.tween_duration,
			camera_tween_settings.tween_trans,
			camera_tween_settings.tween_ease
		)

		var previous_quat: Quaternion = Quaternion(previous_follow_data.get_remote_transform().global_basis.orthonormalized())
		var current_quat: Quaternion = Quaternion(current_follow_data.get_remote_transform().global_basis.orthonormalized())
		quaternion = Tween.interpolate_value(
			previous_quat,
			previous_quat.inverse() * current_quat,
			transition_elapsed_time,
			camera_tween_settings.tween_duration,
			camera_tween_settings.tween_trans,
			camera_tween_settings.tween_ease
		)

		transition_elapsed_time += delta

# region Rotation functions

var _x_rot_input: float = 0.
var _y_rot_input: float = 0.

const ROTATION_INPUT_STOP_WEIGHT: float = 7.5
## Smooth out the rotation input from the user. Runs every time the user
## stops sending input.
func _on_stopped_smooth_rotation_input() -> void:
	_x_rot_input = lerp(_x_rot_input, 0., get_process_delta_time() * ROTATION_INPUT_STOP_WEIGHT)
	_y_rot_input = lerp(_y_rot_input, 0., get_process_delta_time() * ROTATION_INPUT_STOP_WEIGHT)

## Private. Virtual. Clamps the rotation.
func _clamp_rotation() -> void:
	pass

## Private. Virtual. Function to rotate the camera.
func _rotate_camera() -> void:
	pass

const MOUSE_SENSITIVITY: float = .001
## Private. Accepts mouse motion event and set the rotation input variables.
func _rotate_mouse(event: InputEventMouseMotion) -> void:
	# Exit immediately if keyboard is not active
	if !Common.InputState.is_keyboard_active(): return

	var relative: Vector2 = event.relative * MOUSE_SENSITIVITY
	
	if rotation_settings:
		relative *= rotation_settings.mouse_sensitivity
		relative.x *= rotation_settings.get_mouse_x_direction()
		relative.y *= rotation_settings.get_mouse_x_direction()

	_set_rotation_input(relative.x, relative.y)

const JOYPAD_SENSITIVITY: float = .01
## Private. Accepts joypad analog as camera rotation and set the rotation input variables
func _rotate_joypad() -> void:
	# Exit immediately if keyboard is active
	if Common.InputState.is_keyboard_active(): return
	
	var relative: Vector2 = Input.get_vector("camera_left", "camera_right", "camera_up",  "camera_down") * JOYPAD_SENSITIVITY
	if relative == Vector2.ZERO: return
	
	if rotation_settings:
		relative *= rotation_settings.joypad_sensitivity
		relative.x *= rotation_settings.get_joypad_x_direction()
		relative.y *= rotation_settings.get_joypad_y_direction()

	if relative != Vector2.ZERO:
		_set_rotation_input(relative.x, relative.y)
	else:
		_on_stopped_smooth_rotation_input()

## Private. For rotating the virtual camera using euler rotation.
func _set_rotation_input(x_amount: float, y_amount: float) -> void:
	_x_rot_input = lerp(_x_rot_input, x_amount, get_process_delta_time() * 25.)
	_y_rot_input = lerp(_y_rot_input, y_amount, get_process_delta_time() * 25.)

func get_euler_rotation() -> Array:
	return []

func copy_rotation(vc: VirtualCamera) -> void:
	y_rot_target.rotation.y = vc.y_rot_target.rotation.y
	x_rot_target.rotation.x = vc.x_rot_target.rotation.x

# region FoV Functions

var _fov_input: float = actual_fov

## Returns the [actual_fov] of this [VirtualCamera].
func get_fov() -> float:
	return actual_fov

## Private. Lerps the [actual_fov] to [_fov_input].
func _on_stop_smooth_fov_input() -> void:
	if !allow_zoom: return
	actual_fov = lerp(actual_fov, _fov_input, get_process_delta_time() * 5.)

## Private. Clamps the FoV values to its limits specified in the [fov_settings] variable.
func _clamp_fov() -> void:
	if !fov_settings: return
	actual_fov = clamp(actual_fov, fov_settings.fov_limit.x, fov_settings.fov_limit.y)
	_fov_input = clamp(_fov_input, fov_settings.fov_limit.x, fov_settings.fov_limit.y)

const FOV_CHANGE_RATE: float = 2.
## Private. Accepts mouse input for controlling the FoV values.
func _zoom_mouse(event: InputEventMouseButton) -> void:
	if !allow_zoom: return

	if event.button_index == MOUSE_BUTTON_WHEEL_UP:
		_set_fov_input(_fov_input - FOV_CHANGE_RATE)
	if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		_set_fov_input(_fov_input + FOV_CHANGE_RATE)

## Private. Sets the [_fov_input] variable according to player input.
func _set_fov_input(amount: float) -> void:
	_fov_input = amount
