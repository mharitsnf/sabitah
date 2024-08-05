class_name GeotagMemoryMenu extends BaseMenu

@export var memory_title_label: Label
@export var owner_name_label: Label
@export var current_geotag_label: Label
@export var geotag_button_container: GridContainer
@export var geotag_button_pscn: PackedScene

func set_data(new_data: Dictionary) -> void:
	if !new_data.is_empty():
		assert(new_data.has('memory_data'))

		data = new_data
		memory_title_label.text = (data['memory_data'] as MemoryData).get_memory().title
		owner_name_label.text = (data['memory_data'] as MemoryData).get_memory().memory_owner.name
		current_geotag_label.text = GeotagState.get_geotag_name((data['memory_data'] as MemoryData).get_memory().geotag_id)

func _on_geotag_button_pressed(button: GenericButton) -> void:
	current_geotag_label.text = button.text

func _create_geotag_buttons() -> void:
	var geotags: Array[Dictionary] = PictureState.get_available_geotags()
	for tag: Dictionary in geotags:
		var btn: GenericButton = geotag_button_pscn.instantiate()
		(btn as GenericButton).pressed.connect(_on_geotag_button_pressed.bind(btn))
		(btn as GenericButton).text = tag['name']
		(btn as GenericButton).args = [tag['id'], (data['memory_data'] as MemoryData).get_memory()]
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