class_name MainMenu extends BaseMenu

@export var button_vbox: VBoxContainer
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

func set_data(new_data: Dictionary) -> void:
	if new_data.is_empty(): return

	data = new_data

func set_button_visibilities() -> void:
	pass

# Overridden
func about_to_exit() -> void:
	await super()
	active_button.release_focus()

# Overridden
func after_entering() -> void:
	set_button_visibilities()
	
	await super()

	for c: Node in button_vbox.get_children():
		if c is Button and c.visible:
			(c as Button).grab_focus()
			break
