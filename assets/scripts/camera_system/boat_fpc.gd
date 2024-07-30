class_name BoatFirstPersonCamera extends FirstPersonCamera

func delegated_physics_process(_delta: float) -> void:
	_query_star()
	if Input.is_action_just_pressed("actor__mark_star"):
		_create_star_mark()

const CAST_RAY_LENGTH: float = 10000.
func _query_star() -> void:
	var space_state: PhysicsDirectSpaceState3D = State.get_world_3d(State.LevelType.MAIN).direct_space_state

	var origin: Vector3 = main_camera.global_position
	var end: Vector3 = origin + (-main_camera.global_basis.z) * CAST_RAY_LENGTH

	var star_query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(origin, end, star_collision_mask)
	star_query.collide_with_areas = true

	star_query_res = space_state.intersect_ray(star_query)

func _create_star_mark() -> void:
	if State.star_line_mesh:
		State.star_line_mesh.queue_free()
		State.star_line_mesh = null

	if star_query_res.is_empty(): return

	var point_A: Vector3 = star_query_res['collider'].global_position
	var point_B: Vector3 = point_A.normalized() * State.get_planet_data(State.LevelType.MAIN)['radius']
	State.star_line_mesh = Common.Draw.create_line_mesh([point_A, point_B], false)
	State.star_line_mesh.line_radius = 2.5
	var level: Node = State.get_level(State.LevelType.MAIN)
	level.add_child.call_deferred(State.star_line_mesh)