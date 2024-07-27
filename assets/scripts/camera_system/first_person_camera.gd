class_name FirstPersonCamera extends VirtualCamera

@export_group("Parameters")
@export_subgroup("Star detection")
@export_flags_3d_physics var star_collision_mask: int
@export_subgroup("Offset")
@export var offset_target: Node3D
@export var offset: Vector3:
	set(value):
		offset = value
		if offset_target: offset_target.position = value

var final_viewport: Viewport
var star_query_res: Dictionary = {}

func _ready() -> void:
	super()

func delegated_physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("actor__mark_star"):
		_query_star()

func player_input_process(delta: float) -> void:
	super(delta)
	_get_capture_picture_input()

func _get_capture_picture_input() -> void:
	if Input.is_action_just_pressed("camera__capture_picture"):
		_create_picture()

const CAST_RAY_LENGTH: float = 10000.
func _query_star() -> void:
	var space_state: PhysicsDirectSpaceState3D = State.get_world_3d(State.LevelType.MAIN).direct_space_state

	var origin: Vector3 = main_camera.global_position
	var end: Vector3 = origin + (-main_camera.global_basis.z) * CAST_RAY_LENGTH

	var star_query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(origin, end, star_collision_mask)
	star_query.collide_with_areas = true

	star_query_res = space_state.intersect_ray(star_query)
	if State.star_line_mesh:
		State.star_line_mesh.queue_free()
		State.star_line_mesh = null

	if star_query_res.is_empty(): return

	var point_A: Vector3 = star_query_res['collider'].global_position
	var point_B: Vector3 = point_A.normalized() * State.get_planet_data(State.LevelType.MAIN)['radius']
	var points: Array[Vector3] = Common.Geometry.generate_points(point_A, point_B, 5)
	State.star_line_mesh = Common.Draw.create_line_mesh(points, false)
	State.star_line_mesh.line_radius = 2.5
	var level: Node = State.get_level(State.LevelType.MAIN)
	level.add_child.call_deferred(State.star_line_mesh)

func _create_picture() -> void:
	if !final_viewport:
		final_viewport = Group.first("final_viewport")
		assert(final_viewport)

	var img: Image = final_viewport.get_texture().get_image()
	var tex: ImageTexture = ImageTexture.create_from_image(img)

	var final_path: String = PictureState.PICTURE_FOLDER_PATH

	if !DirAccess.dir_exists_absolute(final_path):
		var res: int = DirAccess.make_dir_absolute(final_path)
		if res != Error.OK:
			push_error("Folder could not be created, exiting create picture")
			return

	hud_layer.take_picture_screen()

	var pic: Picture = Picture.new()
	pic.resource_path = final_path + str(floor(Time.get_unix_time_from_system())) + ".res"
	pic.image_tex = tex
	
	PictureState.create_picture_cache(pic)

func _rotate_camera() -> void:
	if !y_rot_target and !x_rot_target: return
	y_rot_target.rotate_object_local(Vector3.UP, _x_rot_input)
	x_rot_target.rotate_object_local(Vector3.RIGHT, _y_rot_input)

func _clamp_rotation() -> void:
	if !clamp_settings or !x_rot_target: return
	x_rot_target.rotation_degrees.x = clamp(x_rot_target.rotation_degrees.x, clamp_settings.limit.x, clamp_settings.limit.y)
