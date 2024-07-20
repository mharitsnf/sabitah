extends Node

enum HelpCategoryVisibility {
	VISIBLE, INVISIBLE
}

const HELP_CATEGORIES_FOLDER_PATH: String = "res://assets/resources/help/categories/"
const HELP_PAGES_FOLDER_PATH: String = "res://assets/resources/help/pages/"

const HELP_MENU_BUTTON_PSCN: PackedScene = preload("res://assets/prefabs/ui_menu/buttons/help_menu_button.tscn")

var help_cache: Array[HelpData] = []

func _ready() -> void:
	load_help_categories()

func load_help_categories() -> void:
	var dir: DirAccess = DirAccess.open(HELP_CATEGORIES_FOLDER_PATH)
	if !dir:
		push_error("Cannot load files!") 
		return

	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	while file_name != "":
		if !dir.current_is_dir():
			var help_category: HelpCategory = load(HELP_CATEGORIES_FOLDER_PATH + file_name)
			create_category_cache(help_category)
		file_name = dir.get_next()

func create_category_cache(help_category: HelpCategory) -> void:
	# see if we have this resource inside the cache already.
	var existing_help_categories: Array[HelpData] = help_cache.filter(
		func(_hd: HelpData) -> bool:
			return _hd.get_help_category().resource_path == help_category.resource_path
	)
	
	# if we have the picture resource inside the cache, return
	if !existing_help_categories.is_empty():
		return
	
	var help_pages: Array[HelpPage] = load_help_pages(help_category.id)

	var help_menu_button: GenericButton = HELP_MENU_BUTTON_PSCN.instantiate()
	(help_menu_button as GenericButton).text = help_category.title
	(help_menu_button as GenericButton).args = [{ "help_category_id": help_category.id }]
	

	help_cache.append(HelpData.new(help_category, help_pages, help_menu_button))

func load_help_pages(folder_name: String) -> Array[HelpPage]:
	var res: Array[HelpPage] = []
	var dir: DirAccess = DirAccess.open(HELP_PAGES_FOLDER_PATH + folder_name)
	if !dir:
		push_error("Cannot load files!") 
		return res

	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	while file_name != "":
		if !dir.current_is_dir():
			var help_page: HelpPage = load(HELP_PAGES_FOLDER_PATH + folder_name + '/' + file_name)
			res.append(help_page)
		file_name = dir.get_next()

	return res

func get_helps(filters: Dictionary = {}) -> Array[HelpData]:
	# example filter:
	# [{ 'status': 'CollectibleStatus.UNOBTAINED' }, { 'type': 'CollectibleType.TREASURE' }]

	var result: Array[HelpData] = help_cache
	for key: String in filters.keys():
		result = result.filter(
			func(hd: HelpData) -> bool:
				return hd.get_help_category().get(key) == filters[key]
		)
	return result

func get_help_by_id(id: String) -> HelpData:
	var hd: Array[HelpData] = help_cache.filter(
		func(_hd: HelpData) -> bool:
			return _hd.get_help_category().id == id
	)
	if hd.is_empty(): return null
	return hd[0]