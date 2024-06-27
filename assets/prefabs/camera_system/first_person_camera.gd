class_name FirstPersonCamera extends VirtualCamera

@export_group("Parameters")
@export_subgroup("Offset")
@export var offset_target: Node3D
@export var offset: Vector3:
	set(value):
		offset = value
		if offset_target: offset_target.position = value

@onready var gimbal: Node3D = $RotationTarget/Gimbal

var final_viewport: Viewport

func _ready() -> void:
	super()

	final_viewport = Group.first("final_viewport")
	assert(final_viewport)

func player_input_process(delta: float) -> void:
	super(delta)
	_get_capture_picture_input()

func _get_capture_picture_input() -> void:
	if Input.is_action_just_pressed("capture_picture"):
		_create_picture()

func _create_picture() -> void:
	var img: Image = final_viewport.get_texture().get_image()
	var tex: ImageTexture = ImageTexture.create_from_image(img)

	if !DirAccess.dir_exists_absolute(State.PICTURE_FOLDER_PATH):
		var res: int = DirAccess.make_dir_absolute(State.PICTURE_FOLDER_PATH)
		if res != Error.OK:
			push_error("Folder could not be created, exiting create picture")
			return

	var pic: Picture = Picture.new()
	pic.resource_path = State.PICTURE_FOLDER_PATH + str(floor(Time.get_unix_time_from_system())) + ".tres"
	pic.image_tex = tex
	var save_state: int = ResourceSaver.save(pic)
	if save_state != Error.OK:
		push_error("Picture could not be saved")

func _rotate_camera() -> void:
	if rotation_target and gimbal: 
		rotation_target.rotate_object_local(Vector3.UP, _x_rot_input)
		gimbal.rotate_object_local(Vector3.RIGHT, _y_rot_input)

func _clamp_rotation() -> void:
	if !clamp_settings or !gimbal: return
	gimbal.rotation_degrees.x = clamp(gimbal.rotation_degrees.x, clamp_settings.limit.x, clamp_settings.limit.y)