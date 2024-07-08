extends Node

enum ClueStatus {
	ACTIVE, COMPLETED
}

const CLUE_FOLDER_PATH: String = "res://assets/resources/clues/"

var clue_area_pscn: PackedScene = preload("res://assets/prefabs/clues/clue_area.tscn")
var clue_menu_button_pscn: PackedScene = preload("res://assets/prefabs/user_interfaces/buttons/clue_menu_button.tscn")

var clue_to_confirm: Clue

var clue_cache: Array[ClueData] = []

func _ready() -> void:
	load_clues()

## Returns true if all clue has its own area instantiated
func all_areas_instantiated() -> bool:
	for cd: ClueData in clue_cache:
		if !cd.get_clue_area():
			push_error('clue ', cd.get_clue().id, " has no area!")
			return false
	return true

func save_clues() -> void:
	for cd: ClueData in clue_cache:
		cd.save_clue()

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

func get_clues_by_status(status: ClueStatus) -> Array[ClueData]:
	var filtered_clues: Array[ClueData] = clue_cache.filter(
		func(cd: ClueData) -> bool:
			return cd.get_clue().status == status
	)
	return filtered_clues

func get_clue_data_from_id(clue_id: String) -> ClueData:
	var cd: Array[ClueData] = clue_cache.filter(
		func(_cd: ClueData) -> bool:
			return _cd.get_clue().id == clue_id
	)
	if cd.is_empty(): return null
	return cd[0]

func get_clue_data_from_area(area: ClueArea) -> ClueData:
	var cd: Array[ClueData] = clue_cache.filter(
		func(_cd: ClueData) -> bool:
			return _cd.get_clue_area() == area
	)
	if cd.is_empty(): return null
	return cd[0]

func create_clue_area() -> ClueArea:
	var ca: ClueArea = clue_area_pscn.instantiate()
	return ca

func create_clue_cache(clue: Clue) -> void:
	# see if we have this resource inside the cache already.
	var existing_clue: Array[ClueData] = clue_cache.filter(
		func(_cd: ClueData) -> bool:
			return _cd.get_clue().resource_path == clue.resource_path
	)
	
	# if we have the picture resource inside the cache, return
	if !existing_clue.is_empty():
		return

	var clue_menu_button: GenericButton = clue_menu_button_pscn.instantiate()
	(clue_menu_button as GenericButton).text = clue.title
	(clue_menu_button as GenericButton).args = [{ "clue": clue, 'is_confirmation': false }]

	clue_cache.append(ClueData.new(clue, clue_menu_button))