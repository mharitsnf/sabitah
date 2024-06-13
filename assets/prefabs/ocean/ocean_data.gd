@tool
class_name OceanData extends Node3D

@export_group("Follow target")
@export var target : BaseActor

@export_group("Wave data")
@export var wave_data_1 : Vector4
@export var wave_data_2 : Vector4
@export var wave_data_3 : Vector4
@export var wave_data_4 : Vector4
@export var wave_data_5 : Vector4
@export var speed : float = 1.

var target_world_pos: Vector3 = Vector3.ZERO
var target_basis: Basis = Basis.IDENTITY

var transitioning: bool = false

# Transform variables
var default_initial_position : Vector3 = Vector3(0., State.Game.PLANET_RADIUS, 0.)
var initial_position : Vector3 = default_initial_position
var initial_basis : Basis = Basis.IDENTITY
var offset : Vector3 = Vector3.ZERO

var time_elapsed : float = 0.

func _process(delta: float) -> void:
    time_elapsed += delta
    _calculate_offset(delta)
    _update_target_transform()

# region Setters and Getters

func get_target() -> Node3D:
    return target

func get_target_basis() -> Basis:
    return target_basis

func get_offset() -> Vector3:
    return offset

func get_offset_normalized() -> Vector3:
    return offset.normalized()

func get_target_position() -> Vector3:
    return target_world_pos

func get_target_position_normalized() -> Vector3:
    return target_world_pos.normalized()

func get_time_elapsed() -> float:
    return time_elapsed

func get_speed() -> float:
    return speed

# region Transformations

func _calculate_offset(delta: float) -> void:
    if !target: return
    if transitioning: return

    if target is RigidBody3D:
        var flat_vel: Vector3 = target.basis.inverse() * target.linear_velocity
        var xz_vel: Vector3 = Vector3(flat_vel.x, 0, flat_vel.z)
        offset += xz_vel * delta
    else:
        var current_flat_pos : Vector3 = initial_basis * target.global_position
        current_flat_pos.y = 0
        offset = current_flat_pos - initial_position

func _update_target_transform() -> void:
    if target and is_instance_valid(target) and !transitioning:
        target_world_pos = target.global_position
        target_basis = target.basis

func get_shader_data() -> Dictionary:
    var _target_pos: Vector3
    var _target_up: Vector3
    var _target_right: Vector3
    var _target_fwd: Vector3
    
    if target and is_instance_valid(target) and !transitioning:
        _target_pos = target.global_position
        _target_up = target.basis.y
        _target_right = target.basis.x
        _target_fwd = target.basis.z
    else:
        _target_pos = target_world_pos
        _target_up = target_basis.y
        _target_right = target_basis.x
        _target_fwd = target_basis.z

    return {
        "planet_radius": State.Game.PLANET_RADIUS,
        "cpu_time": time_elapsed,
        "movement_offset": offset,
        "wave_1": wave_data_1,
        "wave_2": wave_data_2,
        "wave_3": wave_data_3,
        "wave_4": wave_data_4,
        "wave_5": wave_data_5,
        "speed": speed,
        "target_world_position": _target_pos,
        "target_up": _target_up,
        "target_right": _target_right,
        "target_fwd": _target_fwd,
    }