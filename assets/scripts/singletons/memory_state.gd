extends Node

const MEMORY_CATEGORY_FOLDER_PATH: String = "res://assets/resources/memories/categories/"
const MEMORY_FOLDER_PATH: String = "res://assets/resources/memories/memories/"
const MENTAL_IMAGE_FOLDER_PATH: String = "res://assets/resources/memories/mental_images/"

const MEMORY_CATEGORY_MENU_BUTTON_PSCN: PackedScene = preload("res://assets/prefabs/ui_menu/buttons/memory_category_menu_button.tscn")
const MEMORY_MENU_BUTTON_PSCN: PackedScene = preload("res://assets/prefabs/ui_menu/buttons/memory_menu_button.tscn")
const MENTAL_IMAGE_MENU_BUTTON: PackedScene = preload("res://assets/prefabs/ui_menu/buttons/mental_image_menu_button.tscn")

var memory_categories_cache: Array[MemoryCategoryData] = []
var memories_cache: Array[MemoryData] = []
var mental_image_cache: Array[MentalImageData] = []

func _ready() -> void:
	load_memory_categories()
	load_memories()
	load_mental_images()

# region Memory Categories

func load_memory_categories() -> void:
	var dir: DirAccess = DirAccess.open(MEMORY_CATEGORY_FOLDER_PATH)
	if !dir:
		push_error("Cannot load files!") 
		return

	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	while file_name != "":
		if !dir.current_is_dir():
			var memory_category: MemoryCategory = load(MEMORY_CATEGORY_FOLDER_PATH + file_name)
			create_memory_category_cache(memory_category)
		file_name = dir.get_next()

func create_memory_category_cache(memory_category: MemoryCategory) -> void:
	# see if we have this resource inside the cache already.
	var existing_memory_category: Array[MemoryCategoryData] = memory_categories_cache.filter(
		func(_mcd: MemoryCategoryData) -> bool:
			return _mcd.get_memory_category().resource_path == memory_category.resource_path
	)
	
	# if we have the resource inside the cache, return
	if !existing_memory_category.is_empty(): return

	var menu_button: GenericButton = MEMORY_CATEGORY_MENU_BUTTON_PSCN.instantiate()
	menu_button.text = memory_category.title
	menu_button.args = [{ "category_id": memory_category.id }]

	memory_categories_cache.append(MemoryCategoryData.new(memory_category, menu_button))

## Get an array of [MemoryCategoryData] filtered according to [filters].
func get_memory_categories(filters: Dictionary = {}) -> Array[MemoryCategoryData]:
	# example filter:
	# { 'status': 'ClueStatus.HIDDEN' }

	var result: Array[MemoryCategoryData] = memory_categories_cache
	for key: String in filters.keys():
		result = result.filter(
			func(_mcd: MemoryCategoryData) -> bool:
				return _mcd.get_memory_category().get(key) == filters[key]
		)
	return result

# region Memories

func load_memories() -> void:
	var dir: DirAccess = DirAccess.open(MEMORY_FOLDER_PATH)
	if !dir:
		push_error("Cannot load files!") 
		return

	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	while file_name != "":
		if !dir.current_is_dir():
			var memory: Memory = load(MEMORY_FOLDER_PATH + file_name)
			create_memory_cache(memory)
		file_name = dir.get_next()

func save_memories() -> void:
	for md: MemoryData in memories_cache:
		var memory: Memory = md.get_memory()
		ResourceSaver.save(memory)

func create_memory_cache(memory: Memory) -> void:
	# see if we have this resource inside the cache already.
	var existing_memory: Array[MemoryData] = memories_cache.filter(
		func(_md: MemoryData) -> bool:
			return _md.get_memory().resource_path == memory.resource_path
	)
	
	# if we have the resource inside the cache, return
	if !existing_memory.is_empty(): return

	var menu_button: GenericButton = MEMORY_MENU_BUTTON_PSCN.instantiate()
	menu_button.text = memory.title
	menu_button.args = [{ 'memory_id': memory.id }]

	memories_cache.append(MemoryData.new(memory, menu_button))

## Get an array of [MemoryCategoryData] filtered according to [filters].
func get_memories(filters: Dictionary = {}) -> Array[MemoryData]:
	# example filter:
	# { 'status': 'ClueStatus.HIDDEN' }

	var result: Array[MemoryData] = memories_cache
	for key: String in filters.keys():
		result = result.filter(
			func(_md: MemoryData) -> bool:
				return _md.get_memory().get(key) == filters[key]
		)
	return result

# region Mental Images

func load_mental_images() -> void:
	var dir: DirAccess = DirAccess.open(MENTAL_IMAGE_FOLDER_PATH)
	if !dir:
		push_error("Cannot load files!") 
		return

	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	while file_name != "":
		if !dir.current_is_dir():
			var mental_image: MentalImage = load(MENTAL_IMAGE_FOLDER_PATH + file_name)
			create_mental_image_cache(mental_image)
		file_name = dir.get_next()

func create_mental_image_cache(mental_image: MentalImage) -> void:
	# see if we have this resource inside the cache already.
	var existing_mental_image: Array[MentalImageData] = mental_image_cache.filter(
		func(_mid: MentalImageData) -> bool:
			return _mid.get_mental_image().resource_path == mental_image.resource_path
	)
	
	# if we have the resource inside the cache, return
	if !existing_mental_image.is_empty(): return

	var menu_button: MentalImageButton = MENTAL_IMAGE_MENU_BUTTON.instantiate()
	menu_button.texture_rect.texture = mental_image.image_tex
	menu_button.description_label.text = mental_image.description
	menu_button.args = [{ "mental_image_id": mental_image.id }]

	mental_image_cache.append(MentalImageData.new(mental_image, menu_button))

func save_mental_images() -> void:
	for mid: MentalImageData in mental_image_cache:
		var mental_image: MentalImage = mid.get_mental_image()
		ResourceSaver.save(mental_image)

## Get an array of [MemoryCategoryData] filtered according to [filters].
func get_mental_images(filters: Dictionary = {}) -> Array[MentalImageData]:
	# example filter:
	# { 'status': 'ClueStatus.HIDDEN' }

	var result: Array[MentalImageData] = mental_image_cache
	for key: String in filters.keys():
		result = result.filter(
			func(_mid: MentalImageData) -> bool:
				return _mid.get_mental_image().get(key) == filters[key]
		)
	return result