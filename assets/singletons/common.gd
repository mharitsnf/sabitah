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

	static func get_latitude(dot: float) -> float:
		return snappedf(remap(dot, -1., 1., -90., 90.), .01)
	
	static func get_longitude(angle: float, dot_sign: float) -> float:
		var long: float = remap(angle, 0., PI, 0., 180.)
		long = snappedf(long, .01)
		return long if dot_sign > 0. else -long

	## Returns the distance between two vectors, [a] and [b], along a sphere surface of radius [r].
	static func slength(a: Vector3, b: Vector3, r: float) -> float:
		var n_a: Vector3 = a.normalized()
		var n_b: Vector3 = b.normalized()
		var a_dot_b: float = n_a.dot(n_b)
		var rad: float = acos(a_dot_b)
		return r * rad

	## Returns the maximum possible distance between two vectors along a sphere surface of radius [r].
	static func max_slength(r: float) -> float:
		return PI * r

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
