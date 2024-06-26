class_name LatLongSearch extends GlobeMode

var query_res: Dictionary

func delegated_physics_process(_delta: float) -> void:
	search_lat_long()

const CAST_RAY_LENGTH: float = 500.
func search_lat_long() -> void:
	var space_state: PhysicsDirectSpaceState3D = State.get_world_3d(State.LevelType.GLOBE).direct_space_state

	var origin: Vector3 = main_camera.global_position
	var end: Vector3 = origin + (-main_camera.global_basis.z) * CAST_RAY_LENGTH
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = false

	query_res = space_state.intersect_ray(query)
	if query_res.is_empty(): return

	var res: Array = Common.Geometry.point_to_latlng(query_res['normal'])

	# Set text to the HUD.
	hud_layer.set_lat_long_text(res[0], res[1])