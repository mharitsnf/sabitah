class_name GenericButton extends BaseButton

@export var on_press_command: Command

var processing: bool = false
var args: Array = []

func _ready() -> void:
	assert(on_press_command)

func _on_pressed() -> void:
	if processing:
		print("still processing!")
		return
	
	processing = true
	await on_press_command.action(args)
	processing = false
