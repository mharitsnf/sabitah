class_name DeletePictureMenu extends BaseMenu

@export var texture_rect: TextureRect
@export var delete_picture_button: GenericButton


func _ready() -> void:
	super()
	assert(texture_rect)
	assert(delete_picture_button)

func set_data(new_data: Dictionary) -> void:
	if !new_data.is_empty():
		assert(new_data.has('picture'))
		data = new_data
		texture_rect.texture = (data['picture'] as Picture).image_tex
		delete_picture_button.args = [data['picture']]

func after_entering() -> void:
	await super()
	delete_picture_button.grab_focus()