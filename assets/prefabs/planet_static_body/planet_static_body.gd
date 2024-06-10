@tool
class_name PlanetStaticBody extends StaticBody3D

var _scale_dict: Dictionary = {
    State.Game.GameType.MAIN: 1.,
    State.Game.GameType.MINI: .05
}

@export var area_type: State.Game.GameType: set = _set_area_type
@export var show_mesh: bool = true: set = _set_show_mesh

@onready var collision_shape: CollisionShape3D = %CollisionShape3D
@onready var mesh_instance: MeshInstance3D = %MeshInstance3D

func _ready() -> void:
    _set_area_type(area_type)
    _set_show_mesh(show_mesh)

func _set_show_mesh(value: bool) -> void:
    show_mesh = value
    if mesh_instance: mesh_instance.visible = value

func _set_area_type(value: State.Game.GameType) -> void:
    area_type = value
    
    if collision_shape:
        if !Engine.is_editor_hint():
            var planet_data: Dictionary = State.Game.get_planet_data(area_type)
            (collision_shape.shape as SphereShape3D).radius = planet_data['radius']
            (mesh_instance.mesh as SphereMesh).radius = planet_data['radius']
            (mesh_instance.mesh as SphereMesh).height = planet_data['radius'] * 2.
        else:
            (collision_shape.shape as SphereShape3D).radius = State.Game.PLANET_RADIUS * _scale_dict[value]
            (mesh_instance.mesh as SphereMesh).radius = State.Game.PLANET_RADIUS * _scale_dict[value]
            (mesh_instance.mesh as SphereMesh).height = State.Game.PLANET_RADIUS * _scale_dict[value] * 2.