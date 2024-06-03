class_name ThirdPersonCamera extends VirtualCamera

var gimbal: Node3D

func _ready() -> void:
	if !rotation_target: return
	if rotation_target.get_child_count() == 0: return
	gimbal = rotation_target.get_child(0)

func _rotate_smooth() -> void:
	rotation_target.rotate_object_local(Vector3.UP, _x_rot_input)
	gimbal.rotate_object_local(Vector3.RIGHT, _y_rot_input)

func _clamp_rotation() -> void:
	gimbal.rotation_degrees.x = clamp(gimbal.rotation_degrees.x, rotation_limits.x, rotation_limits.y)