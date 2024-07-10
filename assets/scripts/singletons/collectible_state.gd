extends Node

enum CollectibleStatus {
	UNOBTAINED, OBTAINED
}

enum CollectibleType {
	TREASURE
}

const COLLECTIBLE_FOLDER_PATH: String = "res://assets/resources/collectibles/"

var collectible_menu_button_pscn: PackedScene = preload("res://assets/prefabs/user_interfaces/buttons/collectible_menu_button.tscn")

var collectible_cache: Array[CollectibleData] = []

func _ready() -> void:
	load_collectibles()

func load_collectibles() -> void:
	var dir: DirAccess = DirAccess.open(COLLECTIBLE_FOLDER_PATH)
	if !dir:
		push_error("Cannot load files!") 
		return

	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	while file_name != "":
		if !dir.current_is_dir():
			var collectible: Collectible = load(COLLECTIBLE_FOLDER_PATH + file_name)
			create_collectible_cache(collectible)
		file_name = dir.get_next()

func get_collectibles(filters: Dictionary = {}) -> Array[CollectibleData]:
	# example filter:
	# [{ 'status': 'CollectibleStatus.UNOBTAINED' }, { 'type': 'CollectibleType.TREASURE' }]

	var result: Array[CollectibleData] = collectible_cache
	for key: String in filters.keys():
		result = result.filter(
			func(cd: CollectibleData) -> bool:
				return cd.get_collectible().get(key) == filters[key]
		)
	return result

func get_collectible_data_by_id(collectible_id: String) -> CollectibleData:
	var cd: Array[CollectibleData] = collectible_cache.filter(
		func(_cd: CollectibleData) -> bool:
			return _cd.get_collectible().id == collectible_id
	)
	if cd.is_empty(): return null
	return cd[0]

func create_collectible_cache(collectible: Collectible) -> void:
	# see if we have this resource inside the cache already.
	var existing_collectible: Array[CollectibleData] = collectible_cache.filter(
		func(_cd: CollectibleData) -> bool:
			return _cd.get_collectible().resource_path == collectible.resource_path
	)
	
	# if we have the picture resource inside the cache, return
	if !existing_collectible.is_empty():
		return

	var collectible_menu_button: GenericButton = collectible_menu_button_pscn.instantiate()
	(collectible_menu_button as GenericButton).text = collectible.title
	(collectible_menu_button as GenericButton).args = [{ "collectible": collectible }]

	collectible_cache.append(CollectibleData.new(collectible, collectible_menu_button))