class_name PlayerCharacterActor extends CharacterActor

var xz_move_input: Vector2 = Vector2.ZERO

var main_camera: MainCamera

func _ready() -> void:
    super()
    main_camera = Group.first("main_camera")

func _physics_process(_delta: float) -> void:
    _move(main_camera.basis, xz_move_input)

func _process(_delta: float) -> void:
    _rotate_visuals(main_camera.basis, xz_move_input)

func player_input_process(_delta: float) -> void:
    _get_horizontal_input()

## Private. Polls player input for horizontal movement.
func _get_horizontal_input() -> void:
    xz_move_input = Input.get_vector("character_left", "character_right", "character_backward", "character_forward")