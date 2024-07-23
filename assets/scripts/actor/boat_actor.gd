class_name BoatActor extends BaseActor

@export_group("Visuals")
@export var propeller_rotation_speed: float = 50.
@export_group("Horizontal movement")
@export var move_speed: float = 1.
@export var brake_speed: float = 1.
@export_group("Rotation")
@export var rotation_weight: float = 1.
@export_group("References")
@export var trail_particles_l: GPUParticles3D 
@export var trail_particles_r: GPUParticles3D 
@export var propeller_left: MeshInstance3D
@export var propeller_right: MeshInstance3D

func _process(_delta: float) -> void:
	_rotate_propeller()

func _rotate_propeller() -> void:
	var flat_vel: Vector3 = global_basis.inverse() * linear_velocity
	flat_vel = Vector3(flat_vel.x, 0., flat_vel.z)
	var speed: float = flat_vel.length()
	var weight: float = remap(speed, 0., water_speed_limit, 0., 1.)
	propeller_left.rotate_z(weight * get_process_delta_time() * propeller_rotation_speed)
	propeller_right.rotate_z(weight * get_process_delta_time() * propeller_rotation_speed)

func show_trail_particles(gas_input: float) -> void:
	trail_particles_l.emitting = gas_input > 0.
	trail_particles_r.emitting = gas_input > 0.

## Private. Moves the boat forward according to the [ref_basis].
func move_forward(ref_basis: Basis, strength: float) -> void:
	if strength > 0.:
		var dir: Vector3 = ref_basis.z * strength
		dir = dir.normalized()
		apply_central_force(dir * move_speed)

## Private. Brakes the boat.
func brake(strength: float) -> void:
	var flat_vel: Vector3 = basis.inverse() * linear_velocity
	flat_vel = Vector3(flat_vel.x, 0., flat_vel.z)
	
	var speed: float = flat_vel.length()
	var flat_dir: Vector3 = flat_vel.normalized()
	
	var dir: Vector3 = basis * flat_dir

	if speed > 0: apply_central_force(-dir * strength * brake_speed)

## Private. Rotates the boat visuals.
func rotate_visuals(strength: float) -> void:
	if !normal_target:
		push_error("Normal target is not assigned!")
		return
	normal_target.rotate_object_local(Vector3.UP, get_process_delta_time() * -strength * rotation_weight)