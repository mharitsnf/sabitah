class_name FullPicture extends BaseMenu

@export var texture_rect: TextureRect
@export var geotag_btn: GenericButton

func set_data(new_data: Dictionary) -> void:
	super(new_data)
	assert(texture_rect)
	texture_rect.texture = data['texture']

func after_entering() -> void:
	await super()
	geotag_btn.grab_focus()