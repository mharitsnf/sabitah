class_name CameraRotationSettings extends Resource

@export_group("Direction")
@export_subgroup("Mouse")
## When true, swiping to the right moves the camera to the left, and vice versa.
## Referenced from Sketchfab mobile controls.
@export var mouse_invert_x: bool
## When true, swiping up moves the camera down, and vice versa.
## Referenced from Sketchfab mobile controls.
@export var mouse_invert_y: bool
@export_subgroup("Joypad")
## When true, swiping to the right moves the camera to the left, and vice versa.
## Referenced from Sketchfab mobile controls.
@export var joypad_invert_x: bool
## When true, swiping up moves the camera down, and vice versa.
## Referenced from Sketchfab mobile controls.
@export var joypad_invert_y: bool
@export_group("Sensitivity")
@export var mouse_sensitivity: float = 1.
@export var joypad_sensitivity: float = 1.

func get_mouse_x_direction() -> float:
    return int(!mouse_invert_x) * 2 - 1

func get_mouse_y_direction() -> float:
    return int(!mouse_invert_y) * 2 - 1

func get_joypad_x_direction() -> float:
    return int(!joypad_invert_x) * 2 - 1

func get_joypad_y_direction() -> float:
    return int(!joypad_invert_y) * 2 - 1