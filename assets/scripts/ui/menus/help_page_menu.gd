class_name HelpPageMenu extends BaseMenu

@export_group("References")
@export var menu_header: Label
@export var content: Label
@export var content_texture_rect: TextureRect
@export var arrow_left_texture_rect: TextureRect
@export var arrow_right_texture_rect: TextureRect

var index: int = 0

func _ready() -> void:
	super()
	assert(menu_header)
	assert(content)
	assert(content_texture_rect)
	assert(arrow_left_texture_rect)
	assert(arrow_right_texture_rect)

func set_data(new_data: Dictionary) -> void:
	if !new_data.is_empty():
		assert(new_data.has('pages'))
		assert(new_data['pages'] is Array)

		data = new_data

func _input(event: InputEvent) -> void:
	super(event)

func about_to_exit() -> void:
	super()
	index = 0