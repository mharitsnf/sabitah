class_name IslandSearch extends LatLongSearch

@export_group("References")
@export var globe_camera_target: GlobeCameraTarget
@export var level_anim: AnimationPlayer
@export var tpc: ThirdPersonCamera
@export_subgroup("Packed scenes")
@export var waypoint_marker_pscn: PackedScene

var camera: MainCamera

func _ready() -> void:
	super()

	camera = Group.first("main_camera")

	assert(globe_camera_target)
	assert(level_anim)
	assert(tpc)
	assert(camera)

func delegated_unhandled_input(event: InputEvent) -> bool:
	if !super(event): return false
	
	if event.is_action_pressed("select_location_on_globe"):
		_open_island_marker()
		return false

	if event.is_action_pressed("add_waypoint"):
		_add_waypoint()
		return false

	return true

func _on_marker_hover_entered() -> void:
	if marker_query_res.is_empty():
		print("marker_query_res is empty") 
		return

	var island_name: String = "Unknown Island Name"
	
	if marker_query_res['collider'] is IslandMarker:
		island_name = (marker_query_res['collider'] as IslandMarker).sundial_manager.get_island_name()

	if marker_query_res['collider'] is WaypointMarker:
		island_name = (marker_query_res['collider'] as WaypointMarker).get_geotag_data()['name']

	hud_layer.set_island_name_text(island_name)
	hud_layer.show_island_name_panel()

func _on_marker_hover_exited() -> void:
	hud_layer.hide_island_name_panel()

func _open_island_marker() -> void:
	if marker_query_res.is_empty(): return
	
	var island_data: Dictionary = {}
	
	if (marker_query_res['collider'] is IslandMarker):
		island_data = (marker_query_res['collider'] as IslandMarker).sundial_manager.get_geotag_data()
	if (marker_query_res['collider'] is WaypointMarker):
		island_data = (marker_query_res['collider'] as WaypointMarker).get_geotag_data()

	island_data = {
		"geotag_id": island_data['id'],
		"geotag_name": island_data['name'],
	}

	menu_layer.navigate_to(State.UserInterfaces.ISLAND_GALLERY, island_data)
	
	transitioning = true
	await hud_layer.hide_crosshair()
	hud_layer.hide_island_name_panel()
	await globe_camera_target.move_aside()
	transitioning = false

func _add_waypoint() -> void:
	if !marker_query_res.is_empty(): return
	if planet_query_res.is_empty(): return

	var marker: WaypointMarker = waypoint_marker_pscn.instantiate()
	var level: Node = State.get_level(State.LevelType.GLOBE)
	level.add_child.call_deferred(marker)
	await marker.tree_entered
	(marker as WaypointMarker).global_position = planet_query_res['normal'] * State.PLANET_RADIUS * State.MAIN_TO_GLOBE_SCALE

func _on_menu_exited(data: MenuLayer.MenuData) -> void:
	match data.get_key():
		State.UserInterfaces.ISLAND_GALLERY:
			if menu_layer.history_stack.is_empty():
				transitioning = true
				await hud_layer.show_crosshair()
				await globe_camera_target.reset_position()
				transitioning = false