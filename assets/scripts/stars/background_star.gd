class_name BackgroundStar extends Sprite3D

@export var game_visibility_curve: Curve

var data: Dictionary

func _ready() -> void:
	global_position = data['global_position']
	assert(game_visibility_curve)