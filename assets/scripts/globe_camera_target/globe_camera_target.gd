class_name GlobeCameraTarget extends Marker3D

@export var tween_settings: TweenSettings
@export var move_distance: float = 100.

var main_camera: MainCamera

func _ready() -> void:
    main_camera = Group.first("main_camera")
    assert(main_camera)
    assert(tween_settings)

func move_aside() -> void:
    var tween: Tween = create_tween()
    tween.tween_property(self, "position", main_camera.global_basis.x * move_distance, tween_settings.tween_duration).set_ease(tween_settings.tween_ease).set_trans(tween_settings.tween_trans)
    await tween.finished

func reset_position() -> void:
    var tween: Tween = create_tween()
    tween.tween_property(self, "position", Vector3.ZERO, tween_settings.tween_duration).set_ease(tween_settings.tween_ease).set_trans(tween_settings.tween_trans)
    await tween.finished