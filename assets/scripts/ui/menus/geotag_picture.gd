class_name GeotagPicture extends BaseMenu

@export var texture_rect: TextureRect
@export var current_tag_label: Label
@export var geotag_button_container: VBoxContainer
@export var geotag_button_pscn: PackedScene

var current_picture: Picture
var buttons: Array[GenericButton]

func _ready() -> void:
	super()
	assert(texture_rect)
	assert(current_tag_label)
	assert(geotag_button_container)
	assert(geotag_button_pscn)

func set_data(new_data: Dictionary) -> void:
	if !new_data.is_empty():
		data = new_data
		current_picture = (data['picture'] as Picture)

		assert(texture_rect)
		texture_rect.texture = data['texture']

		assert(current_tag_label)
		current_tag_label.text = State.get_geotag_name(current_picture.geotag_id)

func _create_geotag_buttons() -> void:
	pass
	# var geotags: Array[Dictionary] = State.get_available_picture_tags()
	# for tag: Dictionary in geotags:
	# 	var btn: GenericButton = geotag_button_pscn.instantiate()
	# 	(btn as GenericButton).args = []
