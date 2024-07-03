class_name PictureToggleButton extends GenericToggleButton

@export var texture_rect: TextureRect

var assigned_picture: Picture: set = _set_assigned_picture

func _ready() -> void:
	super()
	assert(texture_rect)

func _set_assigned_picture(value: Picture) -> void:
	assigned_picture = value
	args = [value]
	if texture_rect:
		texture_rect.texture = value.image_tex