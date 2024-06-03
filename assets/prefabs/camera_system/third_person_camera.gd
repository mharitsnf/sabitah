class_name ThirdPersonCamera extends VirtualCamera

@export_group("Parameters")
@export var spring_length: float = 5:
	set(value):
		spring_length = value
		if spring_arm: spring_arm.spring_length = value

@onready var gimbal: Node3D = $RotationTarget/SpringArm3D
@onready var spring_arm: SpringArm3D = $RotationTarget/SpringArm3D

func _ready() -> void:
	if spring_arm:
		spring_arm.spring_length = spring_length

func _rotate_smooth() -> void:
	if rotation_target and gimbal: 
		rotation_target.rotate_object_local(Vector3.UP, _x_rot_input)
		gimbal.rotate_object_local(Vector3.RIGHT, _y_rot_input)

func _clamp_rotation() -> void:
	if !clamp_settings or !gimbal: return
	gimbal.rotation_degrees.x = clamp(gimbal.rotation_degrees.x, clamp_settings.limit.x, clamp_settings.limit.y)