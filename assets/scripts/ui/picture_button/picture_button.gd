class_name PictureButton extends Button

@export var on_press_command: MenuNavigateCommand
@export_group("References")
@export var texture_rect: TextureRect

var assigned_picture: Picture: set = _set_assigned_picture

var processing: bool = false

func _ready() -> void:
	assert(texture_rect)

func _set_assigned_picture(value: Picture) -> void:
	assigned_picture = value
	if texture_rect:
		texture_rect.texture = value.image_tex

func _on_pressed() -> void:
	if processing:
		print("still processing!")
		return
	
	var data: Dictionary = {
		"texture": assigned_picture.image_tex
	}

	processing = true
	await on_press_command.action([data])
	processing = false
