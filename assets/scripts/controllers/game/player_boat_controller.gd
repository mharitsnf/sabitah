class_name PlayerBoatController extends PlayerController

@export_group("References")
@export var boat_sundial_manager: SundialManager
@export var dropoff_marker: Marker3D
@export var actor: BoatActor
@export_subgroup("Packed Scenes")
@export var node_sundial_dialogue: DialogueResource

var gas_input: float = 0.
var rotate_input: float = 0.
var brake_input: float = 0.

# region Entry functions

func _ready() -> void:
	super()

	assert(boat_sundial_manager)
	assert(dropoff_marker)
	assert(actor)
	assert(node_sundial_dialogue)

	(State.actor_im as ActorInputManager).current_data_changed.connect(_on_current_data_changed)
	State.teleport_to_node_sundial.connect(_on_teleport_to_node_sundial)

func enter_controller() -> void:
	for ip: InputPrompt in input_prompts.values():
		if ip.active: hud_layer.add_input_prompt(ip)

func exit_controller() -> void:
	for ip: InputPrompt in input_prompts.values():
		hud_layer.remove_input_prompt(ip)

func _add_input_prompts() -> void:
	super()

	var ip_factory: Common.InputPromptFactory = Common.InputPromptFactory.new()

	ip_factory.set_data("F", "Exit boat", true)
	input_prompts['F'] = ip_factory.get_instance()

	ip_factory.set_data("T", "Enter sundial", true)
	input_prompts['T'] = ip_factory.get_instance()

	ip_factory.set_data("G", "Teleport to node island", true)
	input_prompts['G'] = ip_factory.get_instance()

# region Lifecycle functions

func _process(_delta: float) -> void:
	actor.rotate_visuals(rotate_input)

	# Called when this controller is inactive
	_reset_rotate_input_smooth()

func _physics_process(_delta: float) -> void:
	actor.move_forward(actor.normal_target.global_basis, gas_input)
	if brake_input > 0.: actor.brake(brake_input)

func player_input_process(_delta: float) -> void:
	_get_teleport_to_waypoint_input()
	_get_enter_sundial_input()
	_get_exit_ship_input()
	_get_gas_input()
	# _get_brake_input()
	_get_rotate_input()

# region Input functions

func _get_enter_sundial_input() -> void:
	if (State.actor_im as ActorInputManager).transitioning: return
	if Input.is_action_just_pressed("actor__toggle_sundial"):
		var new_pd: ActorData = ActorData.new()
		new_pd.set_instance(boat_sundial_manager)
		State.actor_im.switch_data(new_pd)

func _get_exit_ship_input() -> void:
	if (State.actor_im as ActorInputManager).transitioning: return
	if Input.is_action_just_pressed("actor__toggle_boat"):
		# get actor data for character
		var char_pd: ActorData = (State.actor_im as ActorInputManager).get_player_data(ActorInputManager.PlayerActors.CHARACTER)
		
		# Add character to the level
		var char_inst: Node3D = char_pd.get_instance()
		State.actor_im.add_child.call_deferred(char_inst)
		if !char_inst.is_node_ready(): await char_inst.ready
		else: await char_inst.tree_entered
		(char_inst as BaseActor).setup_spawn(dropoff_marker.global_position)

		# Switch to the character's actor data
		State.actor_im.switch_data(char_pd)

func _get_teleport_to_waypoint_input() -> void:
	if Input.is_action_just_pressed("boat__teleport_to_waypoint"):
		Common.DialogueWrapper.start_dialogue(node_sundial_dialogue, "teleport")

func _get_brake_input() -> void:
	brake_input = Input.get_action_strength("boat__brake")

func _get_gas_input() -> void:
	gas_input = Input.get_action_strength("boat__move_forward")

func _get_rotate_input() -> void:
	rotate_input = Input.get_axis("boat__turn_left", "boat__turn_right")

# region Signal listener functions

func _on_teleport_to_node_sundial() -> void:
	assert(State.node_sundial)
	var waypoint: Marker3D = State.node_sundial.boat_waypoint
	actor.setup_spawn.call_deferred(waypoint.global_position)

const ROTATION_INPUT_WEIGHT: float = 5.
func _reset_rotate_input_smooth() -> void:
	if State.actor_im.get_current_controller() != self:
		rotate_input = lerp(rotate_input, 0., get_process_delta_time() * ROTATION_INPUT_WEIGHT)

func _on_menu_entered(_data: MenuData) -> void:
	_reset_inputs()

func _reset_inputs() -> void:
	gas_input = 0.
	brake_input = 0.

func _on_current_data_changed() -> void:
	if State.actor_im.get_current_controller() != self:
		_reset_inputs()

func _on_area_checker_area_entered(area: Area3D) -> void:
	if area.is_in_group("island_areas"):
		if State.actor_im.get_current_controller() != self: return

		assert(area.get_parent() is LocalSundialManager)
		var lsm: LocalSundialManager = area.get_parent()
		if !(lsm as LocalSundialManager).first_marker_done: return

		(hud_layer as GameHUDLayer).set_island_name_label_text((lsm as LocalSundialManager).get_island_name())
		(hud_layer as GameHUDLayer).show_island_name()

func _on_area_checker_area_exited(area: Area3D) -> void:
	if area.is_in_group("island_areas"):
		pass
