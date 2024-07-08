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

func enter_mode() -> void:
	# Instantiate input prompts
	if input_prompts.is_empty():
		var ip_factory: Common.InputPromptFactory = Common.InputPromptFactory.new()
		
		ip_factory.set_input_button("Q")
		ip_factory.set_prompt("Exit")
		ip_factory.set_active(true)
		input_prompts.append(ip_factory.get_instance())

		ip_factory.set_input_button("E")
		ip_factory.set_prompt("Add waypoint")
		ip_factory.set_active(true)
		input_prompts.append(ip_factory.get_instance())

		ip_factory.set_input_button("LMB")
		ip_factory.set_prompt("Open marker")
		input_prompts.append(ip_factory.get_instance())

		ip_factory.set_input_button("R")
		ip_factory.set_prompt("Erase waypoint")
		input_prompts.append(ip_factory.get_instance())

	_add_input_prompts()

	if !marker_query_res.is_empty():
		hud_layer.show_island_name_panel()

func _add_input_prompts() -> void:
	for ip: InputPrompt in input_prompts:
		if ip.active:
			hud_layer.add_input_prompt(ip)

func exit_mode() -> void:
	for ip: InputPrompt in input_prompts:
		hud_layer.remove_input_prompt(ip)

	await hud_layer.hide_island_name_panel()

func delegated_unhandled_input(event: InputEvent) -> bool:
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

	return true

func _on_marker_hover_entered() -> void:
	if marker_query_res.is_empty(): return

	_show_input_prompt(2)

	var island_name: String = "Unknown Island Name"
	
	if marker_query_res['collider'] is IslandMarker:
		island_name = (marker_query_res['collider'] as IslandMarker).sundial_manager.get_island_name()

	if marker_query_res['collider'] is WaypointMarker:
		island_name = (marker_query_res['collider'] as WaypointMarker).get_geotag_data()['name']
		_show_input_prompt(3)

	hud_layer.set_island_name_text(island_name)
	hud_layer.show_island_name_panel()

func _on_marker_hover_exited() -> void:
	if _is_input_prompt_active(2):
		_hide_input_prompt(3)

	_hide_input_prompt(2)

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
	level_anim.play("move_camera_target_aside")
	await level_anim.animation_finished
	transitioning = false

func _add_waypoint() -> void:
	if !marker_query_res.is_empty(): return
	if planet_query_res.is_empty(): return

	var marker: WaypointMarker = waypoint_marker_pscn.instantiate()
	var level: Node = State.get_level(State.LevelType.GLOBE)
	level.add_child.call_deferred(marker)
	await marker.tree_entered
	(marker as WaypointMarker).global_position = planet_query_res['normal'] * State.PLANET_RADIUS * State.MAIN_TO_GLOBE_SCALE

func _erase_waypoint() -> void:
	if marker_query_res.is_empty(): return
	if !(marker_query_res['collider'] is WaypointMarker): return

	(marker_query_res['collider'] as WaypointMarker).destroy()

func _on_menu_entered(data: MenuLayer.MenuData) -> void:
	match data.get_key():
		State.UserInterfaces.ISLAND_GALLERY:
			_hide_input_prompt(0)
			_hide_input_prompt(1)
			_hide_input_prompt(2)

func _on_menu_exited(data: MenuLayer.MenuData) -> void:
	match data.get_key():
		State.UserInterfaces.ISLAND_GALLERY:
			_show_input_prompt(0)
			if menu_layer.history_stack.is_empty():
				transitioning = true
				await hud_layer.show_crosshair()
				level_anim.play("move_camera_target_default")
				await level_anim.animation_finished
				transitioning = false