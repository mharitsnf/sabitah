class_name FullPicture extends BaseMenu

@export var texture_rect: TextureRect
@export var geotag_label: Label
@export var to_geotag_picture_btn: GenericButton
@export var to_delete_picture_btn: GenericButton

func set_data(new_data: Dictionary) -> void:
	if !new_data.is_empty():
		assert(new_data.has('picture'))

		data = new_data
		texture_rect.texture = (data['picture'] as Picture).image_tex
		geotag_label.text = PictureState.get_geotag_name((data['picture'] as Picture).geotag_id)

		to_geotag_picture_btn.args = [data.duplicate()]
		to_delete_picture_btn.args = [data.duplicate()]
	else:
		geotag_label.text = PictureState.get_geotag_name((data['picture'] as Picture).geotag_id)

func after_entering() -> void:
	await super()
	to_geotag_picture_btn.grab_focus()
