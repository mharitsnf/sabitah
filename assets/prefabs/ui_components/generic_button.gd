class_name GenericButton extends Button

@export var on_press_command: Command

func _ready() -> void:
    assert(on_press_command)

func _on_pressed() -> void:
    on_press_command.action()
