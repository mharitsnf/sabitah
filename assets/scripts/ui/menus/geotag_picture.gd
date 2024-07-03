class_name GeotagPicture extends BaseMenu

@export var texture_rect: TextureRect
@export var current_tag_label: Label
@export var geotag_button_container: VBoxContainer
@export var geotag_button_pscn: PackedScene

var current_picture: Picture

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
		texture_rect.texture = current_picture.image_tex

		assert(current_tag_label)
		current_tag_label.text = PictureState.get_geotag_name(current_picture.geotag_id)

func _on_geotag_button_pressed(button: GenericButton) -> void:
	current_tag_label.text = button.text

func _create_geotag_buttons() -> void:
	var geotags: Array[Dictionary] = PictureState.get_available_geotags()
	for tag: Dictionary in geotags:
		var btn: GenericButton = geotag_button_pscn.instantiate()
		(btn as GenericButton).pressed.connect(_on_geotag_button_pressed.bind(btn))
		(btn as GenericButton).text = tag['name']
		(btn as GenericButton).args = [tag['id'], current_picture]
		geotag_button_container.add_child.call_deferred(btn)

func _free_geotag_buttons() -> void:
	for c: Node in geotag_button_container.get_children():
		(c as GenericButton).pressed.disconnect(_on_geotag_button_pressed)
		c.queue_free()

func about_to_exit() -> void:
	await super()
	_free_geotag_buttons()

func after_entering() -> void:
	_create_geotag_buttons()
	await super()
	(geotag_button_container.get_child(0) as GenericButton).grab_focus()