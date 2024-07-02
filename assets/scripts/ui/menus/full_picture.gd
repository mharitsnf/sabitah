class_name FullPicture extends BaseMenu

@export var texture_rect: TextureRect
@export var geotag_btn: GenericButton
@export var to_delete_picture_btn: GenericButton

func set_data(new_data: Dictionary) -> void:
	if !new_data.is_empty():
		data = new_data

		assert(texture_rect)
		texture_rect.texture = data['texture']

		var to_delete_picture_data: Dictionary = {
			"picture": data['picture'],
			"texture": data['texture']
		}
		to_delete_picture_btn.args = [to_delete_picture_data]

func after_entering() -> void:
	await super()
	geotag_btn.grab_focus()
