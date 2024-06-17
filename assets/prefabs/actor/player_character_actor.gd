class_name PlayerCharacterActor extends CharacterActor

var xz_move_input: Vector2 = Vector2.ZERO

var main_camera: MainCamera

@onready var meshes: Node3D = %Meshes

func _ready() -> void:
    super()
    main_camera = Group.first("main_camera")

func _physics_process(_delta: float) -> void:
    _move(main_camera.basis, xz_move_input)

func _process(_delta: float) -> void:
    _rotate_mesh(main_camera.basis)

func player_input_process(_delta: float) -> void:
    _get_horizontal_input()

## Private. Rotate the mesh based on the direction of movement.
func _rotate_mesh(ref_basis: Basis) -> void:
    if !meshes: return
    if xz_move_input == Vector2.ZERO: return
    
    ref_basis = ref_basis.orthonormalized()
    var dir: Vector3 = (-ref_basis.z * xz_move_input.y + ref_basis.x * xz_move_input.x).normalized()
    dir = basis.inverse() * dir
    dir = Vector3(dir.x, 0., dir.z).normalized()

    var new_quat: Quaternion = Basis.looking_at(dir, meshes.basis.y).get_rotation_quaternion()
    meshes.quaternion = meshes.basis.get_rotation_quaternion().slerp(new_quat, get_process_delta_time() * 10.)

## Private. Polls player input for horizontal movement.
func _get_horizontal_input() -> void:
    xz_move_input = Input.get_vector("character_left", "character_right", "character_backward", "character_forward")