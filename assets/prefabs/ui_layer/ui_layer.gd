class_name UILayer extends CanvasLayer

class UIData extends RefCounted:
    var _ui: Control

    func _init(__ui: Control) -> void:
        _ui = __ui

var history_stack: Array[UIData] = []

func _process(_delta: float) -> void:
    if Input.is_action_just_pressed("toggle_main_menu"):
        print("Main menu toggled")

## Returns the currently active [UIData].
func get_current_data() -> UIData:
    return history_stack.back()