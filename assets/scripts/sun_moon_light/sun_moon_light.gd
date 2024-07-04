class_name SunMoonLight extends DirectionalLight3D

@export var level_type: State.LevelType

@export_group("Max shadow distance settings")
@export var normal_distance: float = 100.
@export var sundial_distance: float = 15.
@export var tween_transition_settings: TweenSettings
@export_group("Intensity settings")
## Should the SunMoonLight adjust its intensity according to the player actor's position?
## Disable this if this sun is for the globe scene.
@export var adjust_intensity: bool = false
@export var intensity_curve: Curve

var transitioning: bool = false

func _ready() -> void:
	assert(tween_transition_settings)

	directional_shadow_max_distance = normal_distance

	if adjust_intensity:
		assert(intensity_curve)

func _process(_delta: float) -> void:
	_look_at_origin()
	_adjust_intensity()

## Switch the shadow distance according to the light type.
func start_shadow_transition(light_type: ActorInputManager.LightType) -> void:
	if transitioning:
		return
	
	var final_val: float = normal_distance if light_type == ActorInputManager.LightType.NORMAL else sundial_distance
	if directional_shadow_max_distance == final_val:
		return
	
	transitioning = true

	var tween: Tween = create_tween()
	tween.tween_property(self, 'directional_shadow_max_distance', final_val, tween_transition_settings.tween_duration).set_trans(tween_transition_settings.tween_trans).set_ease(tween_transition_settings.tween_ease)
	await tween.finished

	transitioning = false

const EPS: Vector3 = Vector3(.001, .001, .001)
## Private. Make the light look at origin every frame.
func _look_at_origin() -> void:
	look_at(Vector3.ZERO + EPS)

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

	var active_actor: Node3D = (State.actor_im as ActorInputManager).current_data.get_instance()
	if !active_actor:
		return
	
	var instance_normal: Vector3 = active_actor.global_basis.y
	var dir_to_instance: Vector3 = (global_position - active_actor.global_position).normalized()
	var ndotl: float = instance_normal.dot(dir_to_instance)
	ndotl = max(ndotl, State.SUNSET_ANGLE)
	ndotl = remap(ndotl, State.SUNSET_ANGLE, 1., 0., 1.)
	light_energy = intensity_curve.sample(ndotl)
