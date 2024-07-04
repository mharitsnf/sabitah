class_name PlayerBoatController extends PlayerController

@export_group("References")
@export var boat_sundial_manager: SundialManager
@export var dropoff_marker: Marker3D
@export var actor: BoatActor

var gas_input: float = 0.
var rotate_input: float = 0.
var brake_input: float = 0.

# region Entry functions

func _ready() -> void:
	super()

	assert(boat_sundial_manager)
	assert(dropoff_marker)
	assert(actor)

	(State.actor_im as ActorInputManager).current_data_changed.connect(_on_current_data_changed)

func enter_controller() -> void:
	if input_prompts.is_empty():
		var ip_factory: Common.InputPromptFactory = Common.InputPromptFactory.new()

		ip_factory.set_input_button("F")
		ip_factory.set_prompt("Exit boat")
		ip_factory.set_active(true)
		input_prompts.append(ip_factory.get_instance())

		ip_factory.set_input_button("T")
		ip_factory.set_prompt("Enter Sundial")
		ip_factory.set_active(true)
		input_prompts.append(ip_factory.get_instance())
	
	for ip: InputPrompt in input_prompts:
		if ip.active: hud_layer.add_input_prompt(ip)

func exit_controller() -> void:
	for ip: InputPrompt in input_prompts:
		hud_layer.remove_input_prompt(ip)

# region Lifecycle functions

func _process(_delta: float) -> void:
	actor.rotate_visuals(rotate_input)

	# Called when this controller is inactive
	_reset_rotate_input_smooth()

func _physics_process(_delta: float) -> void:
	actor.move_forward(actor.normal_target.global_basis, gas_input)
	if brake_input > 0.: actor.brake(brake_input)

func player_input_process(_delta: float) -> void:
	_get_enter_sundial_input()
	_get_exit_ship_input()
	_get_gas_input()
	_get_brake_input()
	_get_rotate_input()

# region Input functions

func _get_enter_sundial_input() -> void:
	if (State.actor_im as ActorInputManager).transitioning: return
	if Input.is_action_just_pressed("toggle_sundial"):
		var new_pd: ActorData = ActorData.new()
		new_pd.set_instance(boat_sundial_manager)
		State.actor_im.switch_data(new_pd)

func _get_exit_ship_input() -> void:
	if (State.actor_im as ActorInputManager).transitioning: return
	if Input.is_action_just_pressed("switch_boat_character"):
		# get actor data for character
		var char_pd: ActorData = (State.actor_im as ActorInputManager).get_player_data(ActorInputManager.PlayerActors.CHARACTER)
		
		# Add character to the level
		var char_inst: Node3D = char_pd.get_instance()
		State.actor_im.add_child.call_deferred(char_inst)
		await char_inst.tree_entered
		char_inst.global_position = dropoff_marker.global_position
		char_inst.basis = Common.Geometry.recalculate_quaternion(char_inst.basis, char_inst.global_position.normalized())

		# Switch to the character's actor data
		State.actor_im.switch_data(char_pd)

func _get_brake_input() -> void:
	brake_input = Input.get_action_strength("boat_backward")

func _get_gas_input() -> void:
	gas_input = Input.get_action_strength("boat_forward")

func _get_rotate_input() -> void:
	rotate_input = Input.get_axis("boat_left", "boat_right")

# region Signal listener functions

const ROTATION_INPUT_WEIGHT: float = 5.
func _reset_rotate_input_smooth() -> void:
	if State.actor_im.get_current_controller() != self:
		rotate_input = lerp(rotate_input, 0., get_process_delta_time() * ROTATION_INPUT_WEIGHT)

func _on_menu_entered(_data: MenuLayer.MenuData) -> void:
	_reset_inputs()

func _reset_inputs() -> void:
	gas_input = 0.
	brake_input = 0.

func _on_current_data_changed() -> void:
	if State.actor_im.get_current_controller() != self:
		_reset_inputs()
