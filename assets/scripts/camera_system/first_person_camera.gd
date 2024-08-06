class_name FirstPersonCamera extends VirtualCamera

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
	if offset_target: offset_target.position = offset

func player_input_process(delta: float) -> void:
	super(delta)
	_get_capture_picture_input()

func _get_capture_picture_input() -> void:
	if Input.is_action_just_pressed("camera__capture_picture"):
		var tex: ImageTexture = _take_picture()
		_create_picture(tex)
		return

	if Input.is_action_just_pressed("debug__create_mental_image"):
		var tex: ImageTexture = _take_picture()
		_create_mental_image(tex)
		return

func _take_picture() -> ImageTexture:
	if !final_viewport:
		final_viewport = Group.first("final_viewport")
		assert(final_viewport)

	var img: Image = final_viewport.get_texture().get_image()
	var tex: ImageTexture = ImageTexture.create_from_image(img)
	return tex

func _create_picture(texture: ImageTexture) -> void:
	var final_path: String = PictureState.PICTURE_FOLDER_PATH

	if !DirAccess.dir_exists_absolute(final_path):
		var res: int = DirAccess.make_dir_absolute(final_path)
		if res != Error.OK:
			push_error("Folder could not be created, exiting create picture")
			return

	hud_layer.take_picture_screen()

	var pic: Picture = Picture.new()
	pic.resource_path = final_path + str(floor(Time.get_unix_time_from_system())) + ".res"
	pic.image_tex = texture
	
	PictureState.create_picture_cache(pic)

func _create_mental_image(texture: ImageTexture) -> void:
	var final_path: String = MemoryState.MENTAL_IMAGE_FOLDER_PATH

	if !DirAccess.dir_exists_absolute(final_path):
		var res: int = DirAccess.make_dir_absolute(final_path)
		if res != Error.OK:
			push_error("Folder could not be created, exiting create picture")
			return

	hud_layer.take_picture_screen()

	var mental_image: MentalImage = MentalImage.new()
	mental_image.resource_path = final_path + str(floor(Time.get_unix_time_from_system())) + ".res"
	mental_image.image_tex = texture
	
	MemoryState.create_mental_image_cache(mental_image)

func _rotate_camera() -> void:
	if !y_rot_target and !x_rot_target: return
	y_rot_target.rotate_object_local(Vector3.UP, _x_rot_input)
	x_rot_target.rotate_object_local(Vector3.RIGHT, _y_rot_input)

func _clamp_rotation() -> void:
	if !clamp_settings or !x_rot_target: return
	x_rot_target.rotation_degrees.x = clamp(x_rot_target.rotation_degrees.x, clamp_settings.limit.x, clamp_settings.limit.y)
