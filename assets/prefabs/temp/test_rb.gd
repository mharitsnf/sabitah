extends RigidBody3D

@export var marker: Marker3D

@onready var nav: NavigationAgent3D = $NavigationAgent3D

const SPHERE_RAD: float = 20.
const MOVE_SPEED: float = 1.

var has_wait_one_frame: bool = false

func _physics_process(_delta: float) -> void:
	if !has_wait_one_frame:
		await get_tree().physics_frame
		has_wait_one_frame = true

	nav.target_position = marker.global_position

	var dist: float = Common.Geometry.slength(nav.target_position, global_position, SPHERE_RAD)
	print(dist)

	var dir: Vector3 = (nav.get_next_path_position() - global_position).normalized()
	# var dir: Vector3 = global_position.slerp(nav.get_next_path_position(), delta * 15.)
	var new_vel: Vector3 = dir * nav.max_speed
	if nav.avoidance_enabled:
		nav.set_velocity(new_vel)
	else:
		_move(new_vel)

func _move(_safe_velocity: Vector3) -> void:
	apply_central_force(_safe_velocity)

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	state.transform.basis = Common.Geometry.adjust_basis_to_normal(state.transform.basis, global_position.normalized())
	_clamp_velocity(state)

const MAX_SPEED: float = 2.
func _clamp_velocity(state: PhysicsDirectBodyState3D) -> void:
	var flat_vel: Vector3 = state.transform.basis.inverse() * state.linear_velocity
	var xz_vel: Vector3 = Vector3(flat_vel.x, 0., flat_vel.z)
	var speed: float = xz_vel.length()
	if speed > MAX_SPEED:
		var limited_vel: Vector3 = xz_vel.normalized() * MAX_SPEED
		limited_vel.y = flat_vel.y
		state.linear_velocity = state.transform.basis * limited_vel
