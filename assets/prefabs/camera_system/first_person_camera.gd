class_name FirstPersonCamera extends VirtualCamera

@export_group("Parameters")
@export_subgroup("Offset")
@export var offset_target: Node3D
@export var offset: Vector3:
	set(value):
		offset = value
		if offset_target: offset_target.position = value

@onready var gimbal: Node3D = $RotationTarget/Gimbal

func _rotate_smooth() -> void:
	if rotation_target and gimbal: 
		rotation_target.rotate_object_local(Vector3.UP, _x_rot_input)
		gimbal.rotate_object_local(Vector3.RIGHT, _y_rot_input)

func _clamp_rotation() -> void:
	if gimbal:
		gimbal.rotation_degrees.x = clamp(gimbal.rotation_degrees.x, rotation_limits.x, rotation_limits.y)