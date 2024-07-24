extends Node

enum Status {
	NONE, SUCCESS, ERROR
}

func _ready() -> void:
	# Input
	InputState._current_device = InputHelper.guess_device_name()
	InputHelper.device_changed.connect(InputState._on_input_device_changed)

func wait(sec: float) -> void:
	await get_tree().create_timer(sec).timeout

signal dialogue_entered
signal dialogue_exited

class DialogueWrapper extends RefCounted:
	static var monologue_res: DialogueResource = preload("res://assets/dialogues/monologues.dialogue")

	static var _dialogue_active: bool = false

	static func is_dialogue_active() -> bool:
		return _dialogue_active

	static func start_monologue(title: String) -> void:
		if is_dialogue_active(): return
		_dialogue_active = true
		Common.dialogue_entered.emit()
		DialogueManager.show_dialogue_balloon(monologue_res, title)
		await DialogueManager.dialogue_ended
		Common.dialogue_exited.emit()
		_dialogue_active = false

	static func start_dialogue(dialogue_resource: DialogueResource, title: String = "start", extra_game_states: Array = []) -> void:
		if is_dialogue_active(): return
		_dialogue_active = true
		Common.dialogue_entered.emit()
		DialogueManager.show_dialogue_balloon(dialogue_resource, title, extra_game_states)
		await DialogueManager.dialogue_ended
		Common.dialogue_exited.emit()
		_dialogue_active = false

class Geometry extends RefCounted:
	static func recalculate_quaternion(old_basis: Basis, new_normal: Vector3) -> Quaternion:
		new_normal = new_normal.normalized()
		var quat : Quaternion = Quaternion(old_basis.y, new_normal).normalized()
		var new_right : Vector3 = quat * old_basis.x
		var new_forward : Vector3 = quat * old_basis.z
		return Quaternion(Basis(new_right, new_normal, new_forward).orthonormalized())

	static func basis_to_euler(basis: Basis) -> Vector3:
		var orientation: Quaternion = basis.get_rotation_quaternion()
		return orientation.get_euler()

	static func normal_to_degrees(normal: Vector3) -> Array:
		var xy: Vector3 = Vector3(normal.x, normal.y, 0.).normalized()
		var xz: Vector3 = Vector3(normal.x, 0., normal.z).normalized()
		var y_angle: float = Vector3.UP.angle_to(xz)
		var x_angle: float = Vector3.RIGHT.angle_to(xy)
		return [y_angle, x_angle]

	static func point_to_latlng(normal: Vector3) -> Array:
		# Calculate latitude vector and dot product with north pole
		var lat_vec: Vector3 = normal
		lat_vec = Vector3(lat_vec.x, lat_vec.y, 0.).normalized() 
		var north_dot_n: float = State.NORTH.dot(lat_vec)

		# Calculate longitude vector
		var long_vec: Vector3 = normal
		long_vec = Vector3(long_vec.x, 0., long_vec.z).normalized()

		# Calculate angle from longitude vector to prime meridian and the sign (west or east of the PM).
		var rotated_long: Vector3 = long_vec.rotated(Vector3.UP, deg_to_rad(-90.)).normalized()
		var pm_dot_long: float = State.PRIME_MERIDIAN.dot(rotated_long)
		var dot_sign: float = signf(pm_dot_long)
		var pm_angle_to_long: float = State.PRIME_MERIDIAN.angle_to(long_vec)

		var lat: float = floorf(remap(north_dot_n, -1., 1., -90., 90.))
		var long: float = floorf(remap(pm_angle_to_long, 0., PI, 0., 180.))
		long = long if dot_sign > 0. else - long

		return [lat, long]

	## Calculate the spherical length between one lat long to another.
	static func haversine_dist(lat1: float, long1: float, lat2: float, long2: float, r: float) -> float:
		var lat1_rad: float = deg_to_rad(lat1)
		var long1_rad: float = deg_to_rad(long1)
		var lat2_rad: float = deg_to_rad(lat2)
		var long2_rad: float = deg_to_rad(long2)

		var dlat: float = lat2_rad - lat1_rad
		var dlong: float = long2_rad - long1_rad

		var a: float = sin(dlat / 2) * sin(dlat / 2) + cos(lat1_rad) * cos(lat2_rad) * sin(dlong / 2) * sin(dlong / 2)
		var c: float = 2 * atan2(sqrt(a), sqrt(1 - a))

		return r * c

	static func generate_points_on_sphere(point_A: Vector3, point_B: Vector3, num_points: int = 100) -> Array[Vector3]:
		var r: float = point_A.length()
		var nA: Vector3 = point_A.normalized()
		var nB: Vector3 = point_B.normalized()
		var result: Array[Vector3] = []
		for i: int in range(num_points):
			var point: Vector3 = nA.slerp(nB, float(i) / float(num_points - 1))
			result.append(point * r)
		return result

class Draw extends RefCounted:
	static var line_mesh_pscn: PackedScene = preload("res://assets/prefabs/globe/markers/line_mesh.tscn")
	static var line_material: StandardMaterial3D = preload("res://assets/resources/materials/m_line_material.tres")
	static var waypoint_marker_pscn: PackedScene = preload("res://assets/prefabs/globe/markers/waypoint_marker.tscn")
	static var island_first_marker_pscn: PackedScene = preload("res://assets/prefabs/globe/markers/globe_first_marker.tscn")

	static func create_line_mesh(points: Array[Vector3]) -> LineMesh:
		var lm: LineMesh = line_mesh_pscn.instantiate()
		(lm as LineMesh).points = points
		return lm

	static func create_waypoint_marker() -> WaypointMarker:
		var wpm: WaypointMarker = waypoint_marker_pscn.instantiate()
		return wpm

	static func create_island_first_marker(sundial: LocalSundialManager) -> IslandMarker:
		var im: IslandMarker = island_first_marker_pscn.instantiate()
		(im as IslandMarker).sundial_manager = sundial
		return im

	static func create_temporary_line() -> MeshInstance3D:
		var mesh_instance: MeshInstance3D = MeshInstance3D.new()
		var mesh: ImmediateMesh = ImmediateMesh.new()

		mesh_instance.mesh = mesh
		mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

		return mesh_instance

	static func update_temporary_line(mesh_instance: MeshInstance3D, points: Array[Vector3]) -> void:
		var mesh: ImmediateMesh = mesh_instance.mesh
		(mesh as ImmediateMesh).clear_surfaces()
		(mesh as ImmediateMesh).surface_begin(Mesh.PRIMITIVE_LINES, line_material)
		for point: Vector3 in points:
			(mesh as ImmediateMesh).surface_add_vertex(point)
		(mesh as ImmediateMesh).surface_end()

class InputState extends RefCounted:
	static var _current_device: String

	static func is_keyboard_active() -> bool:
		return _current_device == InputHelper.DEVICE_KEYBOARD
	
	static func _on_input_device_changed(device: String, _device_index: int) -> void:
		_current_device = device

class InputPromptFactory extends RefCounted:
	var _pscn: PackedScene = preload("res://assets/prefabs/ui_hud/input_prompt/input_prompt.tscn")
	var _instance: InputPrompt
	func _init() -> void:
		_instance = _pscn.instantiate()
	func set_data(_input_button: String, _prompt: String, _active: bool = false) -> void:
		_instance.input_button = _input_button
		_instance.prompt = _prompt
		_instance.active = _active
	func set_active(value: bool) -> void:
		_instance.active = value
	func set_prompt(value: String) -> void:
		_instance.prompt = value
	func set_input_button(value: String) -> void:
		_instance.input_button = value
	func get_instance() -> InputPrompt:
		var inst: InputPrompt = _instance
		_instance = _pscn.instantiate()
		return inst

class Promise extends RefCounted:
	signal completed
	func _init() -> void: completed.emit()

## Factory class for [RemoteTransform3D]
class RemoteTransform3DBuilder extends RefCounted:
	var _rt: RemoteTransform3D
	
	# Constructor
	func _init() -> void:
		reset()
	
	## Resets the current [RemoteTransform3D] instance.
	func reset() -> RemoteTransform3DBuilder:
		_rt = RemoteTransform3D.new()
		_rt.name = "FollowedBy"
		return self

	## Renames the current [RemoteTransform3D].
	func rename(new_name: String) ->  RemoteTransform3DBuilder:
		_rt.name = "FollowedBy" + new_name
		return self
	
	## Set the [update_rotation] value of the [RemoteTransform3D].
	func update_rotation(value: bool = true) -> RemoteTransform3DBuilder:
		_rt.update_rotation = value
		return self
	
	func set_path(path: NodePath) -> RemoteTransform3DBuilder:
		_rt.remote_path = path
		return self

	## Returns the instantiated [RemoteTransform3D], and then resets the instance to a new one.
	func get_remote_transform() -> RemoteTransform3D:
		var result: RemoteTransform3D = _rt
		reset()
		return result

class NavigationAIFactory extends RefCounted:
	var _main_actor: BaseActor

	var _nav_ai_pscn: PackedScene = preload("res://assets/prefabs/navigation/ai/navigation_ai.tscn")
	var _nav_ai: NavigationAI

	func _init(__main_actor: BaseActor) -> void:
		_main_actor = __main_actor
		_nav_ai = _nav_ai_pscn.instantiate()
		(_nav_ai as NavigationAI).max_speed = _main_actor.ground_speed_limit * State.MAIN_TO_NAV_SCALE
		(_nav_ai as NavigationAI).move_speed = (_main_actor as AIActor).move_speed * State.MAIN_TO_NAV_SCALE

	func update_ai_position() -> void:
		var actor_unit_pos: Vector3 = _main_actor.global_position.normalized()
		var planet_data: Dictionary = State.get_planet_data(State.LevelType.NAV)
		_nav_ai.position = (actor_unit_pos * planet_data['radius'])

	func set_ai_target(target: Marker3D) -> void:
		_nav_ai.target = target

	func get_ai_agent() -> NavigationAgent3D:
		return _nav_ai.nav

	func get_ai() -> NavigationAI:
		return _nav_ai

	func add_ai_to_nav_world() -> void:
		if _nav_ai.is_inside_tree():
			return
		
		var level: Node = State.get_level(State.LevelType.NAV)
		level.add_child.call_deferred(_nav_ai)
	
	func remove_ai_from_nav_world() -> void:
		if !_nav_ai.is_inside_tree():
			return
		
		var level: Node = State.get_level(State.LevelType.NAV)
		level.remove_child.call_deferred(_nav_ai)


class NavigationTargetFactory extends RefCounted:
	var _main_target: NavigationTarget
	var _nav_target: Marker3D

	func _init(__main_target: NavigationTarget) -> void:
		_main_target = __main_target

		_nav_target = Marker3D.new()
		_nav_target.name = "RefTo" + _main_target.name

		var planet_data: Dictionary = State.get_planet_data(State.LevelType.NAV)
		_nav_target.position = _main_target.global_position.normalized() * planet_data['radius']

	## Return the navigation target inside the navigation world
	func get_nav_target() -> Marker3D:
		return _nav_target

	## Add the navigation target to the navigation world.
	func add_to_nav_world() -> void:
		if _nav_target.is_inside_tree():
			return
		
		var level: Node = State.get_level(State.LevelType.NAV)
		level.add_child.call_deferred(_nav_target)

	## Remove the navigation target from the navigation world.
	func remove_from_nav_world() -> void:
		if !_nav_target.is_inside_tree():
			return
		
		var level: Node = State.get_level(State.LevelType.NAV)
		level.remove_child.call_deferred(_nav_target)
