class_name HelpData extends RefCounted

var _help_category: HelpCategory
var _help_pages: Array[HelpPage]
var _menu_button: GenericButton

func _init(__help_category: HelpCategory, __help_pages: Array[HelpPage], __menu_button: GenericButton) -> void:
	_help_category = __help_category
	_help_pages = __help_pages
	_menu_button = __menu_button

func set_help_category_visibility(value: HelpState.HelpCategoryVisibility) -> void:
	_help_category.visibility = value

func get_help_category() -> HelpCategory:
	return _help_category

func get_menu_button() -> GenericButton:
	return _menu_button

func get_help_pages() -> Array[HelpPage]:
	return _help_pages

func get_page_count() -> int:
	return _help_pages.size()

func get_page(index: int) -> HelpPage:
	return _help_pages[index]