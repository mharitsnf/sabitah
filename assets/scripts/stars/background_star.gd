class_name BackgroundStar extends Sprite3D

@export var game_visibility_curve: Curve

var data: Dictionary

func _ready() -> void:
	global_position = data['global_position']
	assert(game_visibility_curve)

func _process(_delta: float) -> void:
	_adjust_star_visibility()

func _adjust_star_visibility() -> void:
	var current_instance: Node3D = (State.actor_im.get_current_instance() as Node3D)

	var normal: Vector3 = current_instance.global_position.normalized()
	var dir_to_light: Vector3 = (State.game_sun.global_position - current_instance.global_position).normalized()
	
	var ndotl: float = normal.dot(dir_to_light)
	ndotl = max(ndotl, State.SUNSET_ANGLE)
	ndotl = remap(ndotl, State.SUNSET_ANGLE, 1., 0., 1.)
	
	modulate.a = game_visibility_curve.sample(1. - ndotl)
