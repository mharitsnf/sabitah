class_name LatLongSearch extends GlobeMode

@export_group("Collision")
@export_flags_3d_physics var island_collision_mask: int
@export_flags_3d_physics var planet_collision_mask: int

var marker_query_res: Dictionary
var planet_query_res: Dictionary

signal marker_hover_entered
signal marker_hover_exited

func delegated_process(_delta: float) -> void:
	_update_hud()

func delegated_physics_process(_delta: float) -> void:
	_query_caster()

const CAST_RAY_LENGTH: float = 500.
## Query caster
func _query_caster() -> void:
	var space_state: PhysicsDirectSpaceState3D = State.get_world_3d(State.LevelType.GLOBE).direct_space_state

	var origin: Vector3 = main_camera.global_position
	var end: Vector3 = origin + (-main_camera.global_basis.z) * CAST_RAY_LENGTH
	
	var planet_query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(origin, end, planet_collision_mask)
	planet_query.collide_with_areas = false
	var marker_query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(origin, end, island_collision_mask)
	marker_query.collide_with_areas = false

	planet_query_res = space_state.intersect_ray(planet_query)
	
	var new_marker_query_res: Dictionary = space_state.intersect_ray(marker_query)
	if marker_query_res.is_empty() and !new_marker_query_res.is_empty():
		marker_query_res = new_marker_query_res
		marker_hover_entered.emit()
	if !marker_query_res.is_empty() and new_marker_query_res.is_empty():
		marker_query_res = new_marker_query_res
		marker_hover_exited.emit()

func _update_hud() -> void:
	if planet_query_res.is_empty(): return
	
	var res: Array = Common.Geometry.point_to_latlng(planet_query_res['normal'])

	# Set text to the HUD.
	hud_layer.set_lat_long_text(res[0], res[1])

func _on_marker_hover_entered() -> void:
	pass

func _on_marker_hover_exited() -> void:
	pass