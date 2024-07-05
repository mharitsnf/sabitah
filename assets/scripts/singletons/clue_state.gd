extends Node

enum ClueStatus {
	ACTIVE, COMPLETED
}

const CLUE_FOLDER_PATH: String = "res://assets/resources/clues/"

var clue_destination_area_pscn: PackedScene = preload("res://assets/prefabs/clues/clue_destination_area.tscn")
var clue_menu_button_pscn: PackedScene = preload("res://assets/prefabs/user_interfaces/buttons/clue_menu_button.tscn")

var clue_cache: Array[ClueData] = []

func _ready() -> void:
	load_clues()
	print(clue_cache)

func load_clues() -> void:
	var dir: DirAccess = DirAccess.open(CLUE_FOLDER_PATH)
	if !dir:
		push_error("Cannot load files!") 
		return

	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	while file_name != "":
		if !dir.current_is_dir():
			var clue: Clue = load(CLUE_FOLDER_PATH + file_name)
			create_clue_cache(clue)
		file_name = dir.get_next()

func create_clue_cache(clue: Clue) -> void:
	# see if we have this resource inside the cache already.
	var existing_clue: Array[ClueData] = clue_cache.filter(
		func(_cd: ClueData) -> bool:
			return _cd.get_clue().resource_path == clue.resource_path
	)
	
	# if we have the picture resource inside the cache, return
	if !existing_clue.is_empty():
		return

	# create a new button and picture
	var clue_destination_area: ClueDestinationArea = clue_destination_area_pscn.instantiate()
	clue_destination_area.data = {
		'global_position': clue.destination
	}

	var clue_menu_button: GenericButton = clue_menu_button_pscn.instantiate()
	(clue_menu_button as GenericButton).text = clue.title
	(clue_menu_button as GenericButton).args = [{ "clue": clue }]

	clue_cache.append(ClueData.new(clue, clue_destination_area, clue_menu_button))