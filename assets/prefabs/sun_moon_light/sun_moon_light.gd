class_name SunMoonLight extends DirectionalLight3D

@export var level_type: State.LevelType
@export_group("Intensity settings")
## Should the SunMoonLight adjust its intensity according to the player actor's position?
## Disable this if this sun is for the globe scene.
@export var adjust_intensity: bool = false
@export var intensity_curve: Curve

func _ready() -> void:
    if adjust_intensity:
        assert(intensity_curve)

func _process(_delta: float) -> void:
    _look_at_origin()
    _adjust_intensity()

const EPS: Vector3 = Vector3(.001, .001, .001)
## Private. Make the light look at origin every frame.
func _look_at_origin() -> void:
    look_at(Vector3.ZERO + EPS)

const SUNSET_ANGLE: float = -.25
## Private. Adjust this light intensity according to the dot product of the player's actor position
## and this light position. Only available if the sun is placed in the main world and if [adjust_intensity]
## is true.
func _adjust_intensity() -> void:
    if level_type != State.LevelType.MAIN:
        return

    if !adjust_intensity:
        return

    if !intensity_curve:
        push_error("Curve is not provided!")
        return

    var active_actor: BaseActor = (State.game_pam as PlayerActorManager).current_player_data.get_instance()
    if !active_actor:
        return
    
    var instance_normal: Vector3 = active_actor.basis.y
    var dir_to_instance: Vector3 = (global_position - active_actor.global_position).normalized()
    var ndotl: float = instance_normal.dot(dir_to_instance)
    ndotl = remap(ndotl, SUNSET_ANGLE, 1., 0., 1.)
    light_energy = intensity_curve.sample(ndotl)