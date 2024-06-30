class_name IslandSearch extends LatLongSearch

@export_group("References")
@export var globe_camera_target: GlobeCameraTarget
@export var level_anim: AnimationPlayer
@export var tpc: ThirdPersonCamera

var camera: MainCamera

func _ready() -> void:
	super()

	camera = Group.first("main_camera")

	assert(globe_camera_target)
	assert(level_anim)
	assert(tpc)
	assert(camera)

func player_input_process(delta: float) -> void:
	super(delta)
	_get_select_location_input()

func _on_marker_hover_entered() -> void:
	assert(!marker_query_res.is_empty())

	var island_name: String = "Unknown Island Name"
	
	if marker_query_res['collider'] is IslandMarker:
		if (marker_query_res['collider'] as IslandMarker).sundial_manager.second_marker_done:
			island_name = (marker_query_res['collider'] as IslandMarker).sundial_manager.island_name

	if marker_query_res['collider'] is GlobeMarker:
		if marker_query_res['collider'].marker_name != "":
			island_name = marker_query_res['collider'].marker_name

	hud_layer.set_island_name_text(island_name)
	hud_layer.show_island_name_panel()

func _on_marker_hover_exited() -> void:
	hud_layer.hide_island_name_panel()

func _get_select_location_input() -> void:
	if Input.is_action_just_pressed("select_location_on_globe"):
		if !marker_query_res.is_empty():
			globe_camera_target.move_aside()
			hud_layer.hide_crosshair()
			return
		
		if !planet_query_res.is_empty():
			var screen_pos: Vector2 = camera.unproject_position(planet_query_res['position'])
			print(screen_pos)
			pass

func _create_arbitrary_marker() -> void:
	pass

