class_name BoatActor extends BaseActor

@export_group("Horizontal movement")
@export var move_speed: float = 1.
@export var brake_speed: float = 1.
@export_group("Rotation")
@export var rotation_weight: float = 1.

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