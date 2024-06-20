extends MeshInstance3D

@export var level_type: State.LevelType
var atmosphere_manager: AtmosphereManager

var camera: Camera3D
var sun: DirectionalLight3D
var sm: ShaderMaterial

func _enter_tree() -> void:
    if atmosphere_manager:
        _on_atmosphere_manager_parameter_updated()

func _ready() -> void:
    sm = get_active_material(0)

    atmosphere_manager = Group.first("atmosphere_manager")
    (atmosphere_manager as AtmosphereManager).parameter_updated.connect(_on_atmosphere_manager_parameter_updated)

    match level_type:
        State.LevelType.MAIN:
            camera = State.game_camera
            sun = State.game_sun
        
        State.LevelType.GLOBE:
            camera = State.globe_camera
            sun = State.globe_sun

    assert(camera)
    assert(sun)

    _update_shader()
    _on_atmosphere_manager_parameter_updated()

func _process(_delta: float) -> void:
    _update_shader()

func _on_atmosphere_manager_parameter_updated() -> void:
    var shader_data: Dictionary = atmosphere_manager.get_shader_data(level_type)
    for key: String in shader_data.keys():
        sm.set_shader_parameter(key, shader_data[key])

func _update_shader() -> void:
    sm.set_shader_parameter("fov", camera.fov)
    sm.set_shader_parameter("sun_center", sun.global_position)