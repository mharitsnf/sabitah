@tool
class_name GravityArea extends Area3D

var _game_scale_dict: Dictionary = {
    State.Game.GameType.MAIN: 1.,
    State.Game.GameType.NAV: .05
}

@export var area_type: State.Game.GameType: set = _set_area_type

@onready var collision_shape: CollisionShape3D = %CollisionShape3D

func _ready() -> void:
    _set_area_type(area_type)

func _set_area_type(value: State.Game.GameType) -> void:
    area_type = value
    
    if collision_shape:
        if !Engine.is_editor_hint():
            var gravity_data: Dictionary = State.Game.get_gravity_data(area_type)
            (collision_shape.shape as SphereShape3D).radius = gravity_data['radius']
            gravity = gravity_data['strength']
        else:
            (collision_shape.shape as SphereShape3D).radius = State.Game.PLANET_RADIUS * State.Game.GRAVITY_RADIUS_SCALE * \
            _game_scale_dict[value]

            gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * \
            _game_scale_dict[value]