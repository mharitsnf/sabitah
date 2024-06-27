class_name LatLongSearch extends GlobeMode

@export_group("Switch scene commands")
@export_subgroup("Canceling")
@export var before_cancel_cmd: Command
@export var after_cancel_cmd: Command

var query_res: Dictionary

func delegated_process(_delta: float) -> void:
	_update_hud()

func player_input_process(_delta: float) -> void:
	_get_cancel_input()

func delegated_physics_process(_delta: float) -> void:
	_query_caster()

const CAST_RAY_LENGTH: float = 500.
## Query caster
func _query_caster() -> void:
	var space_state: PhysicsDirectSpaceState3D = State.get_world_3d(State.LevelType.GLOBE).direct_space_state

	var origin: Vector3 = main_camera.global_position
	var end: Vector3 = origin + (-main_camera.global_basis.z) * CAST_RAY_LENGTH
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = false

	query_res = space_state.intersect_ray(query)
	if query_res.is_empty(): return

func _update_hud() -> void:
	if query_res.is_empty(): return
	
	var res: Array = Common.Geometry.point_to_latlng(query_res['normal'])

	# Set text to the HUD.
	hud_layer.set_lat_long_text(res[0], res[1])

func _get_cancel_input() -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		_exit_globe_scene()

func _exit_globe_scene() -> void:
	var scene_manager: SceneManager = Group.first("scene_manager")
	await (scene_manager as SceneManager).switch_scene(
		SceneManager.Scenes.GAME,
		before_cancel_cmd, 
		after_cancel_cmd
	)