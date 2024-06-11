class_name CharacterActor extends BaseActor

@export var move_speed: float = 1.

var xz_move_input: Vector2 = Vector2.ZERO

func _process(_delta: float) -> void:
	_temp_get_player_input()
	# var pj: BaseProjection = projection_factory.get_projection()
	# print(name, " ", pj.get_child(0).scale)

func _physics_process(_delta: float) -> void:
	_move()

# region Horizontal Movement
# =====

# [TEMPORARY] Receive player input and then set the move input
func _temp_get_player_input() -> void:
	var p_input: Vector2 = Input.get_vector("character_right", "character_left", "character_forward", "character_backward")
	_set_move_input(p_input)

const MOVE_INPUT_LERP_WEIGHT: float = 10.
func _set_move_input(value: Vector2) -> void:
	xz_move_input = value

func _move() -> void:
	var dir: Vector3 = -basis.z * xz_move_input.y + basis.x * xz_move_input.x
	dir = dir.normalized()
	apply_central_force(dir * move_speed)