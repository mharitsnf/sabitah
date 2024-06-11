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

## Factory class for creating projection of [BaseActor].
class ProjectionFactory extends RefCounted:
	var _ref: Node3D
	var _ref_world_type: State.Game.GameType
	var _ref_collision: CollisionShape3D
	
	var _world_type: State.Game.GameType
	var _collision: CollisionShape3D

	var _projection_pscn: PackedScene = preload("res://assets/prefabs/actor_projection/base_projection.tscn")
	var _projection: BaseProjection

	var _nav_obstacle_pscn: PackedScene = preload("res://assets/prefabs/navigation_obstacle/navigation_obstacle_3d.tscn")
	var _nav_obstacle: NavigationObstacle3D

	func _init(__ref: Node3D) -> void:
		_ref = __ref
		_projection = _projection_pscn.instantiate()
		(_projection as BaseProjection).reference_node = _ref
		_projection.name = "PJ" + _ref.name
	
	## Sets the reference node world type. Also sets up the projection's world type
	func set_ref_world_type(value: State.Game.GameType) -> void:
		_ref_world_type = value
		_world_type = State.Game.GameType.MAIN if value == State.Game.GameType.MINI else State.Game.GameType.MINI
		_projection.world_type = _world_type

		if _world_type == State.Game.GameType.MINI:
			_nav_obstacle = _nav_obstacle_pscn.instantiate()
			_projection.add_child.call_deferred(_nav_obstacle)
	
	## Sets the reference node collision. Also sets up the projection's collision
	func set_ref_collision(value: CollisionShape3D) -> void:
		_ref_collision = value
		_collision = value.duplicate()

		var mini_scale: float = State.Game.get_scale(State.Game.GameType.MINI)
		match _world_type:
			State.Game.GameType.MAIN: (_collision as CollisionShape3D).scale = Vector3.ONE
			State.Game.GameType.MINI: (_collision as CollisionShape3D).scale = Vector3.ONE * mini_scale
		
		_projection.add_child.call_deferred(_collision)
		_projection.normal_target = _collision

	## Returns the projection node.
	func get_projection() -> BaseProjection:
		return _projection

	## Starts projecting by adding the [_projection] node to the target world.
	func start_projection() -> void:
		if _projection.is_inside_tree(): return

		var target_level: Node = State.Game.get_level(_world_type)
		target_level.add_child.call_deferred(_projection)

	## Stops projecting by removing the [_projection] node from the target world.
	func end_projection() -> void:
		if !_projection.is_inside_tree(): return

		var target_level: Node = State.Game.get_level(_world_type)
		target_level.remove_child.call_deferred(_projection)
