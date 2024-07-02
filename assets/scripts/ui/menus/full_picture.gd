class_name FullPicture extends BaseMenu

@export var texture_rect: TextureRect
@export var geotag_label: Label
@export var to_geotag_picture_btn: GenericButton
@export var to_delete_picture_btn: GenericButton

func set_data(new_data: Dictionary) -> void:
	if !new_data.is_empty():
		data = new_data

		assert(texture_rect)
		texture_rect.texture = data['texture']

		assert(geotag_label)
		geotag_label.text = State.get_geotag_name((data['picture'] as Picture).geotag_id)

		var to_geotag_picture_data: Dictionary = {
			"picture": data['picture'],
			"texture": data['texture']
		}
		to_geotag_picture_btn.args = [to_geotag_picture_data]

		var to_delete_picture_data: Dictionary = to_geotag_picture_data.duplicate()
		to_delete_picture_btn.args = [to_delete_picture_data]

func after_entering() -> void:
	await super()
	to_geotag_picture_btn.grab_focus()
