class_name VirtualCamera extends Node3D

class FollowData extends RefCounted:
	var _target: Node3D
	var _rt: RemoteTransform3D
	
	func _init(__target: Node3D, __rt: RemoteTransform3D) -> void:
		_target = __target
		_rt = __rt
	
	## Mount the remote transform [_rt] to the target [_target].
	func mount_remote_transform() -> void:
		_target.add_child(_rt)

	## Removes the remote transform [_rt] child of the [_target].
	func dismount_remote_transform() -> void:
		_target.remove_child(_rt)

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
@export var camera_use_transition: bool = true
@export var camera_tween_settings: TweenSettings

@export_group("Flags")
## If true, the player is able to control this camera (e.g., rotate with mouse and/or joypad).
@export var allow_player_input: bool = true
## If true, make this camera update its basis relative to the planet surface.
## If this camera is parented to a node that has already been adjusting its basis,
## then activating this property would cancel its effect.
@export var adjusting_basis: bool = true:
	set(value):
		adjusting_basis = value
		if current_follow_data: current_follow_data.set_update_rotation(!value)

@export_group("Rotation")
@export var rotation_target: Node3D
@export_subgroup("Parameters")
@export var rotation_limits: Vector2 = Vector2(-80, 80)

@export_group("Following")
## Who is this [VirtualCamera] currently following?
@export var follow_target: Node3D:
	# This function is first called before the main camera enters the scene tree.
	# Meaning, the change follow target will not work immediately because the path does not exist yet.
	set = _set_follow_target

var previous_follow_data: FollowData
var current_follow_data: FollowData

signal camera_adjusting_basis_changed(new_value: bool)

# region Per-frame functions

func _process(delta: float) -> void:
	_update_basis()

	# Rotation functions
	_clamp_rotation()
	_smooth_rotation_amount(delta)
	_rotate_smooth()

## **Private**. Update the basis according to the normal (if [adjusting_basis] is [true]).
func _update_basis() -> void:
	if adjusting_basis: basis = Common.Geometry.adjust_basis_to_normal(basis, global_position.normalized())

# region Passed functions

func process(_delta: float) -> void:
	if !allow_player_input: return

	_rotate_joypad()

func unhandled_input(event: InputEvent) -> void:
	if !allow_player_input: return

	if event is InputEventMouseMotion:
		_rotate_mouse(event)

# region Follow Target Functions

## Sets a new follow target for the camera.
func _set_follow_target(new_target: Node3D) -> void:
	if !new_target:
		push_error("Unable to set null as the follow target.")
		return
	if follow_target == new_target:
		push_warning("The current follow target is the same as the new one.")
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
	rt_builder.set_path(get_path())
	var rt: RemoteTransform3D = rt_builder.get_remote_transform()
	
	# Dismisses the current follow data
	if current_follow_data:
		current_follow_data.set_remote_path(NodePath(""))
		current_follow_data.dismount_remote_transform()
		previous_follow_data = current_follow_data
	
	# Creates a new follow data for the new follow target
	var new_follow_data: FollowData = FollowData.new(value, rt)
	current_follow_data = new_follow_data
	current_follow_data.mount_remote_transform()

# region Rotation functions

var _x_rot_input: float = 0.
var _y_rot_input: float = 0.

## Smooth out the rotation input from the user. Runs every time the user
## stops sending input.
const ROTATION_AMOUNT_SMOOTHING_WEIGHT: float = 2.5
func _smooth_rotation_amount(delta: float) -> void:
	_x_rot_input = lerp(_x_rot_input, 0., delta * ROTATION_AMOUNT_SMOOTHING_WEIGHT)
	_y_rot_input = lerp(_y_rot_input, 0., delta * ROTATION_AMOUNT_SMOOTHING_WEIGHT)

## Private. Virtual. Clamps the rotation.
func _clamp_rotation() -> void:
	pass

## Private. Virtual. Function to rotate the camera.
func _rotate_smooth() -> void:
	pass

const MOUSE_SENSITIVITY: float = .001
## Private. Accepts mouse motion event and set the rotation input variables.
func _rotate_mouse(event: InputEventMouseMotion) -> void:
	# Exit immediately if keyboard is not active
	if !Common.InputState.is_keyboard_active(): return
	
	var relative: Vector2 = event.relative * MOUSE_SENSITIVITY
	_set_rotation_input(relative.x, relative.y)

const JOYPAD_SENSITIVITY: float = .01
## Private. Accepts joypad analog as camera rotation and set the rotation input variables
func _rotate_joypad() -> void:
	# Exit immediately if keyboard is active
	if Common.InputState.is_keyboard_active(): return
	
	var relative: Vector2 = Input.get_vector("camera_left", "camera_right", "camera_down", "camera_up") * JOYPAD_SENSITIVITY
	if relative == Vector2.ZERO: return
	_set_rotation_input(relative.x, relative.y)

## Private. For rotating the virtual camera using euler rotation.
func _set_rotation_input(x_amount: float, y_amount: float) -> void:
	_x_rot_input = x_amount
	_y_rot_input = y_amount

