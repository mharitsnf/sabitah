class_name MainStar extends Area3D

@export_group("References")
@export var sprite : Sprite3D

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

func _ready() -> void:
	assert(sprite)

	global_position = Vector3( data.np_x, data.np_y, data.np_z, ) * data.distance_from_center
	pulsating = data.is_pulsating
	pulsating_speed = data.pulsating_speed
	alpha_range = Vector2(data.alpha_min, data.alpha_max)
	color = Color(data.color_r, data.color_g, data.color_b, 1)