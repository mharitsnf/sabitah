class_name AIActor extends BaseActor

@export_group("Horizontal Movement")
@export var move_speed: float = 15.
@export_group("Navigation")
@export var target_marker: Marker3D

@onready var nav: NavigationAgent3D = %NavigationAgent3D

var has_wait_one_frame: bool = false

func _enter_tree() -> void:
    super()
    move_speed = move_speed

func _physics_process(_delta: float) -> void:
    _calculate_navigation()

func _calculate_navigation() -> void:
    if !target_marker: return
	
    if !has_wait_one_frame:
        await get_tree().physics_frame
        has_wait_one_frame = true

    nav.target_position = target_marker.global_position

    var next_pos: Vector3 = nav.get_next_path_position()
    var cur_pos: Vector3 = global_position

    var flat_next_pos: Vector3 = basis.inverse() * next_pos
    flat_next_pos = Vector3(flat_next_pos.x, 0., flat_next_pos.z)
    var flat_cur_pos: Vector3 = basis.inverse() * cur_pos
    flat_cur_pos = Vector3(flat_cur_pos.x, 0., flat_cur_pos.z)

    var dir: Vector3 = (flat_next_pos - flat_cur_pos)
    dir = dir.normalized()
    dir = basis * dir

    var new_vel: Vector3 = dir * move_speed
    if nav.avoidance_enabled:
        nav.set_velocity(new_vel)
    else:
        _move(new_vel)

func _move(_safe_velocity: Vector3) -> void:
    # print(_safe_velocity)
    apply_central_force(_safe_velocity)