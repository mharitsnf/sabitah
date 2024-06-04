class_name MainMenu extends BaseMenu

@onready var button_vbox: VBoxContainer = $VBoxContainer
var active_button: Button

func _ready() -> void:
    super()
    assert(button_vbox)
    assert(button_vbox.get_child_count() > 0)

    for c: Node in button_vbox.get_children():
        if !c is Button: continue
        (c as Button).focus_entered.connect(_on_button_focus_entered.bind(c))

func _on_button_focus_entered(button: Button) -> void:
    active_button = button

# Overridden
func about_to_exit() -> Common.Promise:
    await super()
    active_button.release_focus()
    return Common.Promise.new()

# Overridden
func after_entering() -> Common.Promise:
    await super()
    (button_vbox.get_child(0) as Button).grab_focus()
    return Common.Promise.new()