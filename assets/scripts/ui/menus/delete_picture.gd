class_name DeletePicture extends BaseMenu

@export var texture_rect: TextureRect
@export var delete_picture_button: GenericButton

var assigned_picture: Picture

func _ready() -> void:
	super()
	assert(texture_rect)
	assert(delete_picture_button)

func set_data(new_data: Dictionary) -> void:
	if !new_data.is_empty():
		data = new_data

		assert(texture_rect)
		texture_rect.texture = (data['picture'] as Picture).image_tex

		assert(delete_picture_button)
		delete_picture_button.args = [data['picture']]

func after_entering() -> void:
	await super()
	delete_picture_button.grab_focus()