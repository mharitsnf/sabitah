@tool
class_name Ocean extends MeshInstance3D

@export_group("Follow target")
@export var target : Node3D

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
var shader : ShaderMaterial

func _ready() -> void:
    shader = get_active_material(0)
    
func _process(delta: float) -> void:
    time_elapsed += delta
    _calculate_offset(delta)
    _update_target_transform()
    _update_shader_params()

# region Getters

func get_target() -> Node3D:
    return target

func get_target_basis() -> Basis:
    return target_basis

func get_offset() -> Vector3:
    return offset

func get_target_position() -> Vector3:
    return target_world_pos

func get_time_elapsed() -> float:
    return time_elapsed

func get_speed() -> float:
    return speed

# region Transform fn

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

func _update_shader_params() -> void:
    if !shader: return

    shader.set_shader_parameter("planet_radius", State.Game.PLANET_RADIUS)
    shader.set_shader_parameter("cpu_time", time_elapsed)
    shader.set_shader_parameter("movement_offset", offset)
    shader.set_shader_parameter("wave_1", wave_data_1)
    shader.set_shader_parameter("wave_2", wave_data_2)
    shader.set_shader_parameter("wave_3", wave_data_3)
    shader.set_shader_parameter("wave_4", wave_data_4)
    shader.set_shader_parameter("wave_5", wave_data_5)
    shader.set_shader_parameter("speed", speed)

    if mesh is PlaneMesh and (mesh as PlaneMesh).size.x == (mesh as PlaneMesh).size.y:
        shader.set_shader_parameter("plane_size", (mesh as PlaneMesh).size.x)
    
    if target and is_instance_valid(target) and !transitioning:
        shader.set_shader_parameter("target_world_position", target.global_position)
        shader.set_shader_parameter("target_up", target.basis.y)
        shader.set_shader_parameter("target_right", target.basis.x)
        shader.set_shader_parameter("target_fwd", target.basis.z)
    else:
        shader.set_shader_parameter("target_world_position", target_world_pos)
        shader.set_shader_parameter("target_up", target_basis.y)
        shader.set_shader_parameter("target_right", target_basis.x)
        shader.set_shader_parameter("target_fwd", target_basis.z)