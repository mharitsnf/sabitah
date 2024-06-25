extends Node

var hud_layer: GlobeHUDLayer
var main_camera: MainCamera

func _ready() -> void:
	hud_layer = Group.first("hud_layer")
	main_camera = Group.first("main_camera")

	assert(hud_layer)
	assert(main_camera)

const CAST_RAY_LENGTH: float = 500.
func _physics_process(_delta: float) -> void:
	var space_state: PhysicsDirectSpaceState3D = State.get_world_3d(State.LevelType.GLOBE).direct_space_state

	var origin: Vector3 = main_camera.global_position
	var end: Vector3 = origin + (-main_camera.global_basis.z) * CAST_RAY_LENGTH
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = false

	var result: Dictionary = space_state.intersect_ray(query)
	if result.is_empty(): return

	# Calculate latitude vector and dot product with north pole
	var lat_vec: Vector3 = result['normal']
	lat_vec = Vector3(lat_vec.x, lat_vec.y, 0.).normalized() 
	var north_dot_n: float = State.NORTH.dot(lat_vec)

	# Calculate longitude vector
	var long_vec: Vector3 = result['normal']
	long_vec = Vector3(long_vec.x, 0., long_vec.z).normalized()

	# Calculate angle from longitude vector to prime meridian and the sign (west or east of the PM).
	var rotated_long: Vector3 = long_vec.rotated(Vector3.UP, deg_to_rad(-90.)).normalized()
	var pm_dot_long: float = State.PRIME_MERIDIAN.dot(rotated_long)
	var dot_sign: float = signf(pm_dot_long)
	var pm_angle_to_long: float = State.PRIME_MERIDIAN.angle_to(long_vec)

	# Get the lat and long
	var lat: float = Common.Geometry.get_latitude(north_dot_n)
	var long: float = Common.Geometry.get_longitude(pm_angle_to_long, dot_sign)

	# Set text to the HUD.
	hud_layer.set_lat_long_text(lat, long)