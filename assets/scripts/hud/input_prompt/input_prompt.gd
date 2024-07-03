@tool
class_name InputPrompt extends MarginContainer

var input_button_formatted: String = ""
@export var input_button: String:
	set(value):
		input_button = value
		input_button_formatted = "[" + value + "]"
		if button_label: button_label.text = input_button_formatted
@export var prompt: String:
	set(value):
		prompt = value
		if text_label: text_label.text = value
@export_group("References")
@export var button_label: Label
@export var text_label: Label

var active: bool = false