class_name PlayerBoatController extends PlayerController

@export_group("References")
@export var boat_sundial_manager: SundialManager
@export var dropoff_marker: Marker3D
@export var actor: BoatActor

var gas_input: float = 0.
var rotate_input: float = 0.
var brake_input: float = 0.

func _ready() -> void:
	assert(boat_sundial_manager)
	assert(dropoff_marker)
	assert(actor)

	State.game_pam.current_player_data_changed.connect(_on_current_player_data_changed)

func _physics_process(_delta: float) -> void:
	actor.move_forward(actor.normal_target.global_basis, gas_input)
	if brake_input > 0.: actor.brake(brake_input)
	actor.rotate_visuals(rotate_input)

func player_input_process(_delta: float) -> void:
	_get_enter_sundial_input()
	_get_exit_ship_input()
	_get_gas_input()
	_get_brake_input()
	_get_rotate_input()

func _get_enter_sundial_input() -> void:
	if Input.is_action_just_pressed("toggle_boat_sundial"):
		if (State.game_pam as PlayerActorManager).transitioning: return

		var new_pd: PlayerActorManager.PlayerData = PlayerActorManager.PlayerData.new()
		new_pd.set_instance(boat_sundial_manager)
		State.game_pam.change_player_data(new_pd)

func _get_exit_ship_input() -> void:
	if Input.is_action_just_pressed("switch_boat_character"):
		if (State.game_pam as PlayerActorManager).transitioning: return

		var char_pd: PlayerActorManager.PlayerData = State.game_pam.get_player_data(PlayerActorManager.PlayerActors.CHARACTER)
		
		# Add character to the level
		var char_inst: Node3D = char_pd.get_instance()
		State.game_pam.add_child.call_deferred(char_inst)
		await char_inst.tree_entered
		char_inst.global_position = dropoff_marker.global_position
		char_inst.basis = Common.Geometry.recalculate_quaternion(char_inst.basis, char_inst.global_position.normalized())

		State.game_pam.change_player_data(char_pd)

func _get_brake_input() -> void:
	brake_input = Input.get_action_strength("boat_backward")

func _get_gas_input() -> void:
	gas_input = Input.get_action_strength("boat_forward")

func _get_rotate_input() -> void:
	rotate_input = Input.get_axis("boat_left", "boat_right")

func _on_current_player_data_changed() -> void:
	if State.game_pam.current_player_data.get_controller() != self:
		gas_input = 0.
		rotate_input = 0.
		brake_input = 0.
