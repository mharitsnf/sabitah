class_name BaseActor extends RigidBody3D

@export_group("Horizontal movement")
@export var xz_speed_limit: float = 7.5
@export_group("Buoyancy settings")
@export_subgroup("Water normal settings")
## If true, the [normal_target] will adjust its rotation along the water surface normal.
@export var adjust_to_water_normal: bool = false
## The target for adjusting rotation along water surface normal.
@export var normal_target: Node3D
@export_subgroup("Height settings")
## The strength of the upwards force of the actor.
@export var float_force : float = 5.
## The strength of the flat y velocity damping when the actor is submerged.
@export_range(0., 1., .01) var water_drag : float = .1
## The height offset of the ocean_data surface.
@export var ocean_surface_offset : float = 0.

## Describes how far the actor is from the ocean_data surface
var depth_from_ocean_surface : float = 0.
## The current water normal.
var current_normal: Vector3 = Vector3.UP

## Reference to ocean_data node.
var ocean_data: OceanData

func _ready() -> void:
	ocean_data = Group.first("ocean_data")

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if is_inside_tree():
		quaternion = Common.Geometry.recalculate_quaternion(state.transform.basis, global_position.normalized())
		_calculate_depth_from_ocean_surface(state)
		_dampen_y_velocity(state)
		_apply_buoyancy_force()
		_update_to_water_normal(state)

		_clamp_xz_velocity(state)

func delegated_process(_delta: float) -> void:
	pass

func player_input_process(_delta: float) -> void:
	pass

func player_unhandled_input(_event: InputEvent) -> void:
	pass

func setup_spawn(gpos: Vector3) -> void:
	global_position = gpos
	quaternion = Common.Geometry.recalculate_quaternion(basis, gpos.normalized())

# region Horizontal Movement
# =====
func _clamp_xz_velocity(state: PhysicsDirectBodyState3D) -> void:
	var flat_vel: Vector3 = state.transform.basis.inverse() * state.linear_velocity
	var xz_vel: Vector3 = Vector3(flat_vel.x, 0., flat_vel.z)
	var speed: float = xz_vel.length()
	if speed > xz_speed_limit:
		var limited_vel: Vector3 = xz_vel.normalized() * xz_speed_limit
		limited_vel.y = flat_vel.y
		state.linear_velocity = state.transform.basis * limited_vel

# region Buoyancy
# =====

class GerstnerResult extends RefCounted:
	var vertex : Vector3 = Vector3.ZERO
	var normal : Vector3 = Vector3.UP
	var tangent : Vector3 = Vector3.RIGHT
	var binormal : Vector3 = Vector3.BACK
	func _init(_vertex : Vector3, _normal : Vector3, _tangent : Vector3, _binormal : Vector3) -> void:
		vertex = _vertex
		normal = _normal
		tangent = _tangent
		binormal = _binormal

## Returns true if the actor is currently under the water surface.
func is_submerged() -> bool:
	return depth_from_ocean_surface > 0.

const BASIS_LERP_WEIGHT: float = 5.
## Private. Adjusts the [normal_target]'s rotation along the water surface normal.
func _update_to_water_normal(state: PhysicsDirectBodyState3D) -> void:
	if !normal_target:
		push_error("_update_to_water_normal: normal_target is not assigned!")
		return
		
	if adjust_to_water_normal:
		var target_quat: Quaternion = Common.Geometry.recalculate_quaternion(normal_target.basis, current_normal) if is_submerged() else Quaternion.IDENTITY
		normal_target.quaternion = normal_target.quaternion.slerp(target_quat, state.step * BASIS_LERP_WEIGHT)

## Private. Adds upward force to the actor so that it floats above the water surface.
func _apply_buoyancy_force() -> void:
	if depth_from_ocean_surface > 0.:
		apply_central_force(global_basis.y.normalized() * float_force * ProjectSettings.get_setting("physics/3d/default_gravity") * depth_from_ocean_surface)

## Private. Dampens the flat y velocity of this actor.
func _dampen_y_velocity(state: PhysicsDirectBodyState3D) -> void:
	if is_submerged():
		var flat_vel : Vector3 = basis.inverse() * state.linear_velocity
		flat_vel.y *= 1. - water_drag
		state.linear_velocity = basis * flat_vel

## Private. Calculates the depth of the actor relative to the water surface.
func _calculate_depth_from_ocean_surface(state: PhysicsDirectBodyState3D) -> void:
	if !ocean_data:
		push_error("Ocean is not defined")
		return
	if !ocean_data.get_target():
		push_error("Ocean target is not defined")
		return

	var linear_offset : Vector3 = _calculate_offset_to_ocean_target()
	var gerstner_result : GerstnerResult = _calculate_total_gerstner(linear_offset)
	current_normal = gerstner_result.normal
	var flat_position : Vector3 = state.transform.basis.inverse() * global_position
	var water_height : float = State.PLANET_RADIUS + ocean_surface_offset + gerstner_result.vertex.y
	depth_from_ocean_surface = water_height - flat_position.y

## Private. Calculates the distance (offset) from the ocean_data's target to the actor.
func _calculate_offset_to_ocean_target() -> Vector3:
	# Calculate normalized vertex position
	var ocean_target_basis : Basis = ocean_data.get_target_basis()
	var my_flat_pos : Vector3 = ocean_target_basis.inverse() * global_position
	var ocean_target_flat_pos : Vector3 = ocean_target_basis.inverse() * ocean_data.get_target_position()
	var vertex : Vector3 = my_flat_pos - ocean_target_flat_pos
	
	# Scale the vertex according to the game scale
	return Vector3(vertex.x, 0, vertex.z)

## Private. Calculates the total buoyancy across all wave data.
func _calculate_total_gerstner(vertex : Vector3) -> GerstnerResult:
	var tangent : Vector3 = Vector3(1., 0., 0.)
	var binormal : Vector3 = Vector3(0., 0., 1.)
	var gerstner_vertex : Vector3 = (ocean_data.get_offset()) + vertex

	var gerstner_res : GerstnerResult = _calculate_gerstner(ocean_data.wave_data_1, gerstner_vertex)
	gerstner_vertex += gerstner_res.vertex
	tangent += gerstner_res.tangent
	binormal += gerstner_res.binormal

	gerstner_res = _calculate_gerstner(ocean_data.wave_data_2, gerstner_vertex)
	gerstner_vertex += gerstner_res.vertex
	tangent += gerstner_res.tangent
	binormal += gerstner_res.binormal

	gerstner_res = _calculate_gerstner(ocean_data.wave_data_3, gerstner_vertex)
	gerstner_vertex += gerstner_res.vertex
	tangent += gerstner_res.tangent
	binormal += gerstner_res.binormal

	gerstner_res = _calculate_gerstner(ocean_data.wave_data_4, gerstner_vertex)
	gerstner_vertex += gerstner_res.vertex
	tangent += gerstner_res.tangent
	binormal += gerstner_res.binormal

	gerstner_res = _calculate_gerstner(ocean_data.wave_data_5, gerstner_vertex)
	gerstner_vertex += gerstner_res.vertex
	tangent += gerstner_res.tangent
	binormal += gerstner_res.binormal

	gerstner_vertex -= ocean_data.get_offset()
	var normal : Vector3 = binormal.cross(tangent).normalized()
	return GerstnerResult.new(gerstner_vertex, normal, tangent, binormal)

## Private. Calculates the individual wave data buoyancy.
func _calculate_gerstner(wave_data : Vector4, vertex : Vector3) -> GerstnerResult:
	var steepness : float = wave_data.x
	var wavelength : float = wave_data.y
	var direction : Vector2 = Vector2(wave_data.z, wave_data.w)

	var k : float = 2. * PI / wavelength;
	var c : float = sqrt(9.8 / k);
	var d : Vector2 = direction.normalized();
	var f : float = k * (d.dot(Vector2(vertex.x, vertex.z)) - (ocean_data.get_time_elapsed() * c * ocean_data.get_speed()))
	var a : float = steepness / k

	var d_tangent : Vector3 = Vector3(
		- d.x * d.x * (steepness * sin(f)),
		d.x * (steepness * cos(f)), 
		- d.x * d.y * (steepness * sin(f))
	)

	var d_binormal : Vector3 = Vector3(
		- d.x * d.y * (steepness * sin(f)),
		d.y * (steepness * cos(f)),
		- d.y * d.y * (steepness * sin(f))
	)

	var d_vert : Vector3 = Vector3(
		d.x * (a * cos(f)),
		a * sin(f),
		d.y * (a * cos(f))
	)

	return GerstnerResult.new(d_vert, Vector3.UP, d_tangent, d_binormal)
