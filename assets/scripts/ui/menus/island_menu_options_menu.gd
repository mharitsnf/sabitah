class_name IslandMenuOptionsMenu extends BaseMenu

@export var island_title_label: Label
@export var gallery_button: GenericButton
@export var memories_button: GenericButton

func set_data(new_data: Dictionary) -> void:
	if !new_data.is_empty():
		data = new_data

		island_title_label.text = data['geotag_name']

		gallery_button.args = [data]
		memories_button.args = [data]

func after_entering() -> void:
	await super()
	gallery_button.grab_focus()