class_name IslandSearch extends LatLongSearch

@export_group("References")
@export var level_anim: AnimationPlayer
@export var tpc: ThirdPersonCamera

func _ready() -> void:
	super()
	assert(level_anim)
	assert(tpc)

func player_input_process(delta: float) -> void:
	super(delta)
	_get_select_location_input()

func _get_select_location_input() -> void:
	if Input.is_action_just_pressed("select_location_on_globe"):
		if island_query_res:
			print(Common.Geometry.normal_to_degrees(island_query_res['normal']))
			return
		
		if planet_query_res:
			var euler: Vector3 = Common.Geometry.basis_to_euler(tpc.gimbal.global_basis)
			print([rad_to_deg(euler.y), rad_to_deg(euler.x)], tpc.get_euler_rotation())