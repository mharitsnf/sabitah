class_name NavigationAI extends RigidBody3D

@export var target: Marker3D
@export_group("Buoyancy")
## The strength of the upwards force of the actor.
@export var float_force : float = 5.
@export_range(0., 1., .01) var water_drag : float = .1
@export_group("Horizontal movement settings")
@export var move_speed: float
@export var max_speed: float:
	set(value):
		max_speed = value
		if nav: nav.max_speed = value
@export_group("References")
@export var nav: NavigationAgent3D

var depth_from_ocean_surface: float = 0.

var has_wait_one_frame: bool = false

func _ready() -> void:
	nav.max_speed = max_speed

func _physics_process(_delta: float) -> void:
	if !target: return
	
	if !has_wait_one_frame:
		await get_tree().physics_frame
		has_wait_one_frame = true

	nav.target_position = target.global_position

	var next_pos: Vector3 = basis.inverse() * nav.get_next_path_position()
	var flat_next_pos: Vector3 = Vector3(next_pos.x, 0., next_pos.z)
	var cur_pos: Vector3 = basis.inverse() * global_position
	var flat_cur_pos: Vector3 = Vector3(cur_pos.x, 0., cur_pos.z)

	var dir: Vector3 = (flat_next_pos - flat_cur_pos).normalized()
	dir = basis * dir

	var new_vel: Vector3 = dir * move_speed
	if nav.avoidance_enabled:
		nav.set_velocity(new_vel)
	else:
		_move(new_vel)

func _move(_safe_velocity: Vector3) -> void:
	apply_central_force(_safe_velocity.normalized() * move_speed)

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	_adjust_quaternion(state)
	_calculate_depth_from_ocean_surface(state)
	_dampen_y_velocity(state)
	_apply_buoyancy_force()
	
	_clamp_xz_velocity(state)

## Private. Adds upward force to the actor so that it floats above the water surface.
func _apply_buoyancy_force() -> void:
	if depth_from_ocean_surface > 0.:
		apply_central_force(global_basis.y.normalized() * float_force * ProjectSettings.get_setting("physics/3d/default_gravity") * depth_from_ocean_surface)

func _calculate_depth_from_ocean_surface(state: PhysicsDirectBodyState3D) -> void:
	var planet_data: Dictionary = State.get_planet_data(State.LevelType.NAV)
	var flat_position: Vector3 = state.transform.basis.inverse() * global_position
	var water_height: float = planet_data['radius']
	depth_from_ocean_surface = water_height - flat_position.y

## Private. Dampens the flat y velocity of this actor.
func _dampen_y_velocity(state: PhysicsDirectBodyState3D) -> void:
	if depth_from_ocean_surface > 0.:
		var flat_vel : Vector3 = basis.inverse() * state.linear_velocity
		flat_vel.y *= 1. - water_drag
		state.linear_velocity = basis * flat_vel

func _adjust_quaternion(state: PhysicsDirectBodyState3D) -> void:
	quaternion = Common.Geometry.recalculate_quaternion(state.transform.basis, global_position.normalized())

func _clamp_xz_velocity(state: PhysicsDirectBodyState3D) -> void:
	var flat_vel: Vector3 = state.transform.basis.inverse() * state.linear_velocity
	var xz_vel: Vector3 = Vector3(flat_vel.x, 0., flat_vel.z)
	var speed: float = xz_vel.length()
	if speed > max_speed:
		var limited_vel: Vector3 = xz_vel.normalized() * max_speed
		limited_vel.y = flat_vel.y
		state.linear_velocity = state.transform.basis * limited_vel