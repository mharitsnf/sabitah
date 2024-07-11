class_name PictureButton extends GenericButton

@export var texture_rect: TextureRect

var assigned_picture: Picture: set = _set_assigned_picture

func _set_assigned_picture(value: Picture) -> void:
	assigned_picture = value
	args = [{ 'picture': value }]
	if texture_rect:
		texture_rect.texture = value.image_tex