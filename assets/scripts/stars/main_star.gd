class_name MainStar extends Area3D

@export_group("References")
@export var sprite : Sprite3D
@export var game_visibility_curve: Curve
@export var globe_visibility_curve: Curve

var data: Dictionary = {}

var pulsating : bool = false:
	set(value):
		pulsating = value
		if value: pulsating_speed = 1.
		else: pulsating_speed = -1.
		if sprite: sprite.modulate.a = 1

var pulsating_speed : float = -1.
var alpha_range : Vector2 = Vector2(0, 1)
var color : Color = Color(1,1,1):
	set(value):
		color = value
		if sprite: sprite.modulate = value

var sun: SunLight

func _ready() -> void:
	assert(sprite)

	global_position = Vector3( data.np_x, data.np_y, data.np_z, ) * data.distance_from_center
	pulsating = data.is_pulsating
	pulsating_speed = data.pulsating_speed
	alpha_range = Vector2(data.alpha_min, data.alpha_max)
	color = Color(data.color_r, data.color_g, data.color_b, 1)

	sun = State.game_sun if data['level_type'] == State.LevelType.MAIN else State.globe_sun
	
	assert(sun)
	assert(game_visibility_curve)
	assert(globe_visibility_curve)

func _process(_delta: float) -> void:
	_adjust_star_visibility()

func _adjust_star_visibility() -> void:
	var planet_radius: float = State.get_planet_data(data['level_type'])['radius']
	var current_instance: Node3D = (State.actor_im.get_current_instance() as Node3D)

	var normal: Vector3 = sun.global_position.normalized() if data['level_type'] == State.LevelType.GLOBE \
	else current_instance.global_position.normalized()

	var sun_surface: Vector3 = normal * planet_radius
	var dir_to_light: Vector3 = (global_position - sun_surface).normalized() if data['level_type'] == State.LevelType.GLOBE \
	else (sun.global_position - current_instance.global_position).normalized()
	
	var ndotl: float = normal.dot(dir_to_light)
	ndotl = max(ndotl, State.SUNSET_ANGLE)
	ndotl = remap(ndotl, State.SUNSET_ANGLE, 1., 0., 1.)
	
	sprite.modulate.a = globe_visibility_curve.sample(1. - ndotl) if data['level_type'] == State.LevelType.GLOBE \
	else game_visibility_curve.sample(1. - ndotl)