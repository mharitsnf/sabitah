class_name AIActor extends BaseActor

@export var nav_target: NavigationTarget
@export_group("Horizontal Movement")
@export var move_speed: float = 15.

var nav_ai_factory: Common.NavigationAIFactory

func _enter_tree() -> void:
	if !nav_ai_factory:
		nav_ai_factory = Common.NavigationAIFactory.new(self)
	nav_ai_factory.update_ai_position()
	nav_ai_factory.set_ai_target(nav_target.get_nav_target())

	nav_ai_factory.add_ai_to_nav_world()

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	super(state)
	_move_actor()

func _move_actor() -> void:
	var planet_data: Dictionary = State.get_planet_data(State.LevelType.MAIN)
	var ai_pos: Vector3 = nav_ai_factory.get_ai().global_position
	var ai_pos_planet: Vector3 = ai_pos.normalized() * planet_data['radius']
	
	var dist: float = (ai_pos_planet - global_position).length()
	var dir: Vector3 = (ai_pos.normalized() - global_position.normalized()).normalized()
	
	apply_central_force(dir * move_speed * dist * 2.)

func _exit_tree() -> void:
	nav_ai_factory.remove_ai_from_nav_world()