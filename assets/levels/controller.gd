extends Node

@export var main_camera: MainCamera
@export var vc1: VirtualCamera
@export var vc2: VirtualCamera

func _process(_delta: float) -> void:
    if Input.is_action_just_pressed("ui_up"):
        main_camera.follow_target = vc1

    if Input.is_action_just_pressed("ui_down"):
        main_camera.follow_target = vc2