class_name BackgroundStar extends Sprite3D

@export var game_visibility_curve: Curve

var data: Dictionary

var sun: SunLight

func _ready() -> void:
	global_position = data['global_position']
	assert(game_visibility_curve)

	sun = State.game_sun
	assert(sun)
	(sun as SunLight).sunrise_started.connect(_on_sunrise_started)
	(sun as SunLight).sunset_started.connect(_on_sunset_started)

func _on_sunrise_started() -> void:
	if modulate.a != 0:
		var tween: Tween = create_tween()
		tween.tween_property(
			self, 'modulate', Color(modulate.r, modulate.g, modulate.b, 0), 10.
		).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
		await tween.finished

func _on_sunset_started() -> void:
	if modulate.a == 0:
		var tween: Tween = create_tween()
		tween.tween_property(
			self, 'modulate', Color(modulate.r, modulate.g, modulate.b, 1), 10.
		).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
		await tween.finished