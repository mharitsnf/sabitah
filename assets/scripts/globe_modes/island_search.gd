class_name IslandSearch extends LatLongSearch

@export_group("References")
@export var globe_camera_target: GlobeCameraTarget
@export var level_anim: AnimationPlayer
@export var tpc: ThirdPersonCamera
@export var lines_parent: Node3D
@export var waypoints_parent: Node3D

var first_point: Vector3 = Vector3.ZERO
var second_point: Vector3 = Vector3.ZERO

var camera: MainCamera

# region Lifecycle functions

func _ready() -> void:
	super()

	camera = Group.first("main_camera")

	assert(globe_camera_target)
	assert(level_anim)
	assert(tpc)
	assert(camera)

func enter_controller() -> void:
	Common.InputPromptManager.add_to_hud_layer(hud_layer, [
		'Q', 'E_Waypoint', 'T_CreateLine', 'T_ConfirmLine', 'LMB_OpenMarker', 'R'
	])

	Common.InputPromptManager.show_input_prompt([
		'Q', 'E_Waypoint', 'T_CreateLine',
	])

	if !marker_query_res.is_empty():
		hud_layer.show_island_name_panel()

func exit_controller() -> void:
	Common.InputPromptManager.remove_from_hud_layer(hud_layer, [
		'Q', 'E_Waypoint', 'T_CreateLine', 'T_ConfirmLine', 'LMB_OpenMarker', 'R'
	])

	first_point = Vector3.ZERO

	await hud_layer.hide_island_name_panel()

func bool_unhandled_input(event: InputEvent) -> bool:
	if !super(event): return false
	
	if event.is_action_pressed("globe__select_location"):
		_open_island_marker()
		return false

	if event.is_action_pressed("globe__add_waypoint"):
		_add_waypoint()
		return false

	if event.is_action_pressed("globe__erase_waypoint"):
		_erase_waypoint()
		return false

	if event.is_action_pressed("globe__add_line_point"):
		_add_line_point()
		return false

	return true

func delegated_process(delta: float) -> void:
	super(delta)
	_draw_temporary_line()

func player_unhandled_input(event: InputEvent) -> void:
	bool_unhandled_input(event)

# region Signals

func _on_marker_hover_entered() -> void:
	if marker_query_res.is_empty(): return

	Common.InputPromptManager.hide_input_prompt(["E_Waypoint"])

	if first_point == Vector3.ZERO:
		Common.InputPromptManager.show_input_prompt(["LMB_OpenMarker"])

	var island_name: String = "Unknown Island Name"
	
	if marker_query_res['collider'] is IslandMarker:
		island_name = (marker_query_res['collider'] as IslandMarker).sundial_manager.get_island_name()

	if marker_query_res['collider'] is WaypointMarker:
		island_name = (marker_query_res['collider'] as WaypointMarker).get_geotag_data()['name']
		if first_point == Vector3.ZERO:
			Common.InputPromptManager.show_input_prompt(["R"])

	hud_layer.set_island_name_text(island_name)
	hud_layer.show_island_name_panel()

func _on_marker_hover_exited() -> void:
	Common.InputPromptManager.hide_input_prompt(["R", "LMB_OpenMarker"])
	Common.InputPromptManager.show_input_prompt(["E_Waypoint"])

	hud_layer.hide_island_name_panel()

func _on_line_hover_entered() -> void:
	if first_point == Vector3.ZERO:
		Common.InputPromptManager.show_input_prompt(["R"])

func _on_line_hover_exited() -> void:
	Common.InputPromptManager.hide_input_prompt(["R"])

func _on_menu_entered(data: MenuData) -> void:
	match data.get_key():
		State.MENU_ISLAND_GALLERY:
			Common.InputPromptManager.hide_input_prompt([
				"Q", "E_Waypoint", "T_CreateLine", "T_ConfirmLine"
			])

func _on_menu_exited(data: MenuData) -> void:
	match data.get_key():
		State.MENU_ISLAND_GALLERY:
			Common.InputPromptManager.show_input_prompt([
				"Q", "E_Waypoint", "T_CreateLine", "T_ConfirmLine"
			])
			if menu_layer.history_stack.is_empty():
				transitioning = true
				await hud_layer.show_crosshair()
				level_anim.play("move_camera_target_default")
				await level_anim.animation_finished
				transitioning = false

# region Player inputs

func _open_island_marker() -> void:
	if first_point != Vector3.ZERO: return
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

	menu_layer.navigate_to(State.MENU_ISLAND_GALLERY, island_data)
	
	transitioning = true
	await hud_layer.hide_crosshair()
	hud_layer.hide_island_name_panel()
	level_anim.play("move_camera_target_aside")
	await level_anim.animation_finished
	transitioning = false

func _add_waypoint() -> void:
	if first_point != Vector3.ZERO: return
	if !marker_query_res.is_empty(): return
	if planet_query_res.is_empty(): return

	var marker: WaypointMarker = Common.Draw.create_waypoint_marker()
	waypoints_parent.add_child.call_deferred(marker)
	await marker.tree_entered
	(marker as WaypointMarker).global_position = planet_query_res['normal'] * State.PLANET_RADIUS * State.MAIN_TO_GLOBE_SCALE

func _erase_waypoint() -> void:
	if first_point != Vector3.ZERO: return

	if !marker_query_res.is_empty():
		if !(marker_query_res['collider'] is WaypointMarker): return
		(marker_query_res['collider'] as WaypointMarker).destroy()
		return

	if !line_query_res.is_empty():
		if !(line_query_res['collider'] is LineMesh): return
		(line_query_res['collider'] as LineMesh).queue_free()

func _add_line_point() -> void:
	if planet_query_res.is_empty(): return
	if first_point == Vector3.ZERO:
		first_point = planet_query_res['position']

		Common.InputPromptManager.hide_input_prompt([
			'E_Waypoint', "T_CreateLine", 'R', 'LMB_OpenMarker'
		])

		Common.InputPromptManager.show_input_prompt([
			'T_ConfirmLine'
		])

	else:
		second_point = planet_query_res['position']
		var points: Array[Vector3] = Common.Geometry.generate_points_on_sphere(first_point, second_point)
		var lm: LineMesh = Common.Draw.create_line_mesh(points)
		lines_parent.add_child.call_deferred(lm)
		
		first_point = Vector3.ZERO
		second_point = Vector3.ZERO

		Common.InputPromptManager.hide_input_prompt([
			'T_ConfirmLine'
		])

		Common.InputPromptManager.show_input_prompt([
			'E_Waypoint', 'T_CreateLine'
		])

var temp_line_mesh: MeshInstance3D
func _draw_temporary_line() -> void:
	if first_point != Vector3.ZERO:
		if !temp_line_mesh:
			temp_line_mesh = Common.Draw.create_temporary_line()
			lines_parent.add_child.call_deferred(temp_line_mesh)

		var points: Array[Vector3] = Common.Geometry.generate_points_on_sphere(first_point, planet_query_res['position'])
		Common.Draw.update_temporary_line(temp_line_mesh, points)
	else:
		if temp_line_mesh:
			temp_line_mesh.queue_free()
			temp_line_mesh = null

