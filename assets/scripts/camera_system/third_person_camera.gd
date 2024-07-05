class_name ThirdPersonCamera extends VirtualCamera

## If disabled, the camera will zoom with spring length instead of fov.
@export_group("Spring length zoom")
@export var zoom_with_spring_length: bool = false
@export var spring_length_change_rate: float = 10.
@export var spring_length_limit: Vector2 = Vector2(0., 100.)
@export_group("Tween")
@export var set_rotation_tween_settings: TweenSettings
@export_group("Parameters")
@export var offset: Vector3
@export_flags_3d_physics var spring_arm_collision_mask: int:
	set(value):
		spring_arm_collision_mask = value
		if spring_arm: spring_arm.collision_mask = spring_arm_collision_mask
@export var spring_length: float = 5:
	set(value):
		spring_length = value
		if spring_arm: spring_arm.spring_length = value

@export_group("References")
@export_subgroup("Rotation")
@export var gimbal: Node3D
@export var spring_arm: SpringArm3D
@export_subgroup("Offset")
@export var offset_node: Node3D

const OFFSET_LERP_WEIGHT: float = 5.

var _spring_length_input: float = spring_length

func _ready() -> void:
	super()
	_spring_length_input = spring_length
	if spring_arm:
		spring_arm.spring_length = spring_length
		spring_arm.collision_mask = spring_arm_collision_mask

func _process(delta: float) -> void:
	super(delta)
	_lerp_offset()

	_on_stop_smooth_spring_length_input()
	_clamp_spring_length()

func _tween_spring_length(target: float) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "spring_length", target, fov_tween_settings.tween_duration).set_ease(fov_tween_settings.tween_ease).set_trans(fov_tween_settings.tween_trans)
	await tween.finished
	_spring_length_input = spring_length

func tween_spring_length_to_100() -> void:
	await _tween_spring_length(100.)

func tween_spring_length_to_default() -> void:
	await _tween_spring_length(150.)

func _lerp_offset() -> void:
	offset_node.position = lerp(offset_node.position, offset, get_process_delta_time() * OFFSET_LERP_WEIGHT)

var target_y_rotation: float = 0.
var target_x_rotation: float = 0.
func set_euler_rotation(y: float, x: float) -> void:
	target_y_rotation = y
	target_x_rotation = x

func lerp_euler_rotation_to_target_rotation() -> void:
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(rotation_target, 'rotation', Vector3(0., target_y_rotation, 0.), set_rotation_tween_settings.tween_duration).set_ease(set_rotation_tween_settings.tween_ease).set_trans(set_rotation_tween_settings.tween_trans)
	tween.tween_property(gimbal, 'rotation', Vector3(target_x_rotation, 0., 0.), set_rotation_tween_settings.tween_duration).set_ease(set_rotation_tween_settings.tween_ease).set_trans(set_rotation_tween_settings.tween_trans)
	await tween.finished

func get_euler_rotation() -> Array:
	return [
		rotation_target.rotation.y,
		gimbal.rotation.x,
	]

func _zoom_mouse(event: InputEventMouseButton) -> void:
	if !allow_zoom: return

	if zoom_with_spring_length:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_set_spring_length_input(spring_length - spring_length_change_rate)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_set_spring_length_input(spring_length + spring_length_change_rate)
	else:
		super(event)

func _set_spring_length_input(amount: float) -> void:
	_spring_length_input = amount

## Private. Lerps the [actual_fov] to [_fov_input].
func _on_stop_smooth_spring_length_input() -> void:
	if !allow_zoom: return
	spring_length = lerp(spring_length, _spring_length_input, get_process_delta_time() * 5.)

## Private. Clamps the FoV values to its limits specified in the [fov_settings] variable.
func _clamp_spring_length() -> void:
	if !fov_settings: return
	spring_length = clamp(spring_length, spring_length_limit.x, spring_length_limit.y)
	_spring_length_input = clamp(_spring_length_input, spring_length_limit.x, spring_length_limit.y)

func _rotate_camera() -> void:
	if !rotation_target and !gimbal: return
	rotation_target.rotate_object_local(Vector3.UP, _x_rot_input)
	gimbal.rotate_object_local(Vector3.RIGHT, _y_rot_input)

func _clamp_rotation() -> void:
	if !clamp_settings or !gimbal: return
	gimbal.rotation_degrees.x = clamp(gimbal.rotation_degrees.x, clamp_settings.limit.x, clamp_settings.limit.y)
