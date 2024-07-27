class_name MainStar extends Area3D

@export_group("References")
@export var sprite : Sprite3D
@export var anim: AnimationPlayer
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
	assert(anim)

	global_position = Vector3( data.np_x, data.np_y, data.np_z, ) * data.distance_from_center
	pulsating = data.is_pulsating
	pulsating_speed = data.pulsating_speed
	alpha_range = Vector2(data.alpha_min, data.alpha_max)
	color = Color(data.color_r, data.color_g, data.color_b, 1)
	sprite.scale *= data.scale

	sun = State.game_sun if data['level_type'] == State.LevelType.MAIN else State.globe_sun
	assert(sun)
	(sun as SunLight).sunrise_started.connect(_on_sunrise_started)
	(sun as SunLight).sunset_started.connect(_on_sunset_started)
	
	assert(game_visibility_curve)
	assert(globe_visibility_curve)

# func _process(_delta: float) -> void:
# 	sprite.modulate.a = sun.get_star_intensity()

const DAYTIME_VISIBILITY: float = .1

func _on_sunrise_started() -> void:
	if sprite.modulate.a != DAYTIME_VISIBILITY:
		var tween: Tween = create_tween()
		tween.tween_property(
			sprite, 'modulate', Color(color.r, color.g, color.b, DAYTIME_VISIBILITY), 10.
		).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
		await tween.finished

func _on_sunset_started() -> void:
	if sprite.modulate.a != 1:
		var tween: Tween = create_tween()
		tween.tween_property(
			sprite, 'modulate', Color(color.r, color.g, color.b, 1), 10.
		).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
		await tween.finished