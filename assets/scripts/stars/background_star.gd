class_name BackgroundStar extends Sprite3D

var data: Dictionary

func _ready() -> void:
	global_position = data['global_position']