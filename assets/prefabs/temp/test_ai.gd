extends RigidBody3D

@export var marker: Marker3D
@export var actor_projection_pscn: PackedScene
@export var collision: CollisionShape3D
@export var visual: Node3D
var actor_projection: ActorProjection

@onready var nav: NavigationAgent3D = $NavigationAgent3D

var world_type: State.Game.GameType
var projection_factory: Common.ProjectionFactory

var velocity_scale: float = 1.
var has_wait_one_frame: bool = false

func _enter_tree() -> void:
	world_type = State.Game.get_world_type(get_world_3d())

	if !projection_factory:
		projection_factory = Common.ProjectionFactory.new(self)
		projection_factory.set_ref_world_type(world_type)
		projection_factory.set_ref_collision(collision)
	
	projection_factory.start_projection()

func _exit_tree() -> void:
	projection_factory.end_projection()

func _physics_process(_delta: float) -> void:
	if !marker: return
	
	if !has_wait_one_frame:
		await get_tree().physics_frame
		has_wait_one_frame = true

	nav.target_position = marker.global_position

	var dist: float = Common.Geometry.slength(nav.target_position, global_position, State.Game.PLANET_RADIUS)
	dist = min(200., dist)
	velocity_scale = remap(dist, 0., 100., 0., 1.)

	var next_pos: Vector3 = nav.get_next_path_position()
	next_pos = basis.inverse() * next_pos
	var flat_next_pos: Vector3 = Vector3(next_pos.x, 0., next_pos.z)
	var cur_pos: Vector3 = basis.inverse() * global_position
	var flat_cur_pos: Vector3 = Vector3(cur_pos.x, 0., cur_pos.z)

	var dir: Vector3 = (flat_next_pos - flat_cur_pos).normalized()
	dir = basis * dir

	var new_vel: Vector3 = dir * 5.
	if nav.avoidance_enabled:
		nav.set_velocity(new_vel)
	else:
		_move(new_vel)

func _move(_safe_velocity: Vector3) -> void:
	# linear_velocity = _safe_velocity
	# apply_central_force(_safe_velocity * velocity_scale)
	apply_central_force(_safe_velocity)

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	quaternion = Common.Geometry.recalculate_quaternion(state.transform.basis, global_position.normalized())
	_clamp_velocity(state)

func _clamp_velocity(state: PhysicsDirectBodyState3D) -> void:
	var flat_vel: Vector3 = state.transform.basis.inverse() * state.linear_velocity
	var xz_vel: Vector3 = Vector3(flat_vel.x, 0., flat_vel.z)
	var speed: float = xz_vel.length()
	if speed > nav.max_speed:
		var limited_vel: Vector3 = xz_vel.normalized() * nav.max_speed
		limited_vel.y = flat_vel.y
		state.linear_velocity = state.transform.basis * limited_vel