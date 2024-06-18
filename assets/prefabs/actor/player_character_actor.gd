class_name PlayerCharacterActor extends CharacterActor

var xz_move_input: Vector2 = Vector2.ZERO

var main_camera: MainCamera
var pam: PlayerActorManager

func _ready() -> void:
    super()
    main_camera = Group.first("main_camera")
    pam = get_parent() as PlayerActorManager

func _physics_process(_delta: float) -> void:
    _move(main_camera.basis, xz_move_input)

func _process(_delta: float) -> void:
    _rotate_visuals(main_camera.basis, xz_move_input)

func player_input_process(_delta: float) -> void:
    _get_enter_boat_input()
    _get_horizontal_input()

func _get_enter_boat_input() -> void:
    if Input.is_action_just_pressed("switch_actor"):
        if State.Game.game_pam.transitioning: return
        
        var next_pd: PlayerActorManager.PlayerData = State.Game.game_pam.get_player_data(PlayerActorManager.PlayerActors.BOAT)
        var res: Array = await State.Game.game_pam.change_player_data(next_pd)
        if res[0] as bool:
            State.Game.game_pam.remove_child.call_deferred((res[1] as PlayerActorManager.PlayerData).get_instance())

## Private. Polls player input for horizontal movement.
func _get_horizontal_input() -> void:
    xz_move_input = Input.get_vector("character_left", "character_right", "character_backward", "character_forward")