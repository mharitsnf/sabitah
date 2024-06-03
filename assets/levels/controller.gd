extends Node

@export var main_camera: MainCamera
@export var vc1: VirtualCamera
@export var vc2: VirtualCamera

func _process(_delta: float) -> void:
    if Input.is_key_pressed(KEY_1):
        main_camera.follow_target = vc1

    if Input.is_key_pressed(KEY_2):
        main_camera.follow_target = vc2