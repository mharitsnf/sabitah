class_name HelpPageMenu extends BaseMenu

@export_group("References")
@export var menu_header: Label
@export var content: Label
@export var content_texture_rect: TextureRect
@export var arrow_left_texture_rect: TextureRect
@export var arrow_right_texture_rect: TextureRect

var index: int = 0: set = _set_index

func _ready() -> void:
	super()
	assert(menu_header)
	assert(content)
	assert(content_texture_rect)
	assert(arrow_left_texture_rect)
	assert(arrow_right_texture_rect)

func set_data(new_data: Dictionary) -> void:
	if !new_data.is_empty():
		assert(new_data.has('help_category_id'))
		assert(new_data['help_category_id'] is String)

		data = new_data
		var help_data: HelpData = HelpState.get_help_by_id(data['help_category_id'])
		data['help_category'] = help_data.get_help_category()
		data['pages'] = help_data.get_help_pages()

		menu_header.text = (data['help_category'] as HelpCategory).title

		_set_index_content()

func _set_index(value: int) -> void:
	index = value
	_set_index_content()

func _set_index_content() -> void:
	var page: HelpPage = (data['pages'] as Array[HelpPage])[index]
	content_texture_rect.texture = page.image_tex
	content.text = page.content

	if index == 0:
		arrow_left_texture_rect.modulate.a = 0
	else:
		arrow_left_texture_rect.modulate.a = 1
	
	if index == (data['pages'] as Array[HelpPage]).size()-1:
		arrow_right_texture_rect.modulate.a = 0
	else:
		arrow_right_texture_rect.modulate.a = 1

func _input(event: InputEvent) -> void:
	super(event)

	if event.is_action_pressed("ui_right"):
		index = clamp(index + 1, 0, (data['pages'] as Array[HelpPage]).size()-1)
		game_viewport.set_input_as_handled()

	if event.is_action_pressed("ui_left"):
		index = clamp(index - 1, 0, (data['pages'] as Array[HelpPage]).size()-1)
		game_viewport.set_input_as_handled()

func after_entering() -> void:
	index = 0
	super()
