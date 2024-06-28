@tool
class_name Ocean extends MeshInstance3D

var shader : ShaderMaterial
var ocean_data: OceanData

func _ready() -> void:
    if Engine.is_editor_hint():
        ocean_data = %OceanData
    else:
        ocean_data = Group.first("ocean_data")
    
    shader = get_active_material(0)
    
func _process(_delta: float) -> void:
    _update_shader()

func _update_shader() -> void:
    if !ocean_data: return

    var shader_data: Dictionary = ocean_data.get_shader_data()
    for key: String in shader_data.keys():
        shader.set_shader_parameter(key, shader_data[key])
    
    if mesh is PlaneMesh and (mesh as PlaneMesh).size.x == (mesh as PlaneMesh).size.y:
        shader.set_shader_parameter("plane_size", (mesh as PlaneMesh).size.x)