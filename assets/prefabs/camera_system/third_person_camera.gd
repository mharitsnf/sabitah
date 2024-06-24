class_name ThirdPersonCamera extends VirtualCamera

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

func _ready() -> void:
	super()
	if spring_arm:
		spring_arm.spring_length = spring_length
		spring_arm.collision_mask = spring_arm_collision_mask

func _process(delta: float) -> void:
	super(delta)
	_lerp_offset()

func _lerp_offset() -> void:
	offset_node.position = lerp(offset_node.position, offset, get_process_delta_time() * OFFSET_LERP_WEIGHT)

func _rotate_camera() -> void:
	if !rotation_target and !gimbal: return
	rotation_target.rotate_object_local(Vector3.UP, _x_rot_input)
	gimbal.rotate_object_local(Vector3.RIGHT, _y_rot_input)

func _clamp_rotation() -> void:
	if !clamp_settings or !gimbal: return
	gimbal.rotation_degrees.x = clamp(gimbal.rotation_degrees.x, clamp_settings.limit.x, clamp_settings.limit.y)
