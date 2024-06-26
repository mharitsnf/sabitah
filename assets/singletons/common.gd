extends Node

func _ready() -> void:
	# Input
	InputState.current_device = InputHelper.guess_device_name()
	InputHelper.device_changed.connect(InputState._on_input_device_changed)

func wait(sec: float) -> void:
	await get_tree().create_timer(sec).timeout

class Geometry extends RefCounted:
	static func recalculate_quaternion(old_basis: Basis, new_normal: Vector3) -> Quaternion:
		new_normal = new_normal.normalized()
		var quat : Quaternion = Quaternion(old_basis.y, new_normal).normalized()
		var new_right : Vector3 = quat * old_basis.x
		var new_forward : Vector3 = quat * old_basis.z
		return Quaternion(Basis(new_right, new_normal, new_forward).orthonormalized())

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

class InputState extends RefCounted:
	static var current_device: String

	static func is_keyboard_active() -> bool:
		return current_device == InputHelper.DEVICE_KEYBOARD
	
	static func _on_input_device_changed(device: String, _device_index: int) -> void:
		current_device = device

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
		(_nav_ai as NavigationAI).max_speed = _main_actor.xz_speed_limit * State.MAIN_TO_NAV_SCALE
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
