class_name GenericToggleButton extends Button

@export var on_toggle_true_command: Command
@export var on_toggle_false_command: Command

var args: Array = []

var processing: bool = false

func _ready() -> void:
	assert(on_toggle_true_command)
	assert(on_toggle_false_command)

func _on_toggled(toggled_on:bool) -> void:
	if processing:
		print("Still processing!")
		return

	processing = true
	if toggled_on:
		await on_toggle_true_command.action(args)
	else:
		await on_toggle_false_command.action(args)
	processing = false
