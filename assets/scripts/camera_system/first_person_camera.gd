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

func player_input_process(delta: float) -> void:
	super(delta)
	_get_capture_picture_input()

func _get_capture_picture_input() -> void:
	if Input.is_action_just_pressed("camera__capture_picture"):
		_create_picture()

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
