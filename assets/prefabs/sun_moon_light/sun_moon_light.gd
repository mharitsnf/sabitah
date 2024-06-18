class_name SunMoonLight extends DirectionalLight3D

@export_group("Intensity settings")
## Should the SunMoonLight adjust its intensity according to the player actor's position?
## Disable this if this sun is for the globe scene.
@export var adjust_intensity: bool = false
## The maximum intensity for this light.
@export var max_intensity: float = 1.

const EPS: Vector3 = Vector3(.001, .001, .001)
func _process(_delta: float) -> void:
    look_at(Vector3.ZERO + EPS)