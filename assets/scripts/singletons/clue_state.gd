extends Node

enum ClueStatus {
	HIDDEN, ACTIVE, COMPLETED
}

const CLUE_FOLDER_PATH: String = "res://assets/resources/clues/"

var check_dialogue: DialogueResource = preload("res://assets/dialogues/clue_checking.dialogue")
var clue_area_pscn: PackedScene = preload("res://assets/prefabs/clues/clue_area.tscn")
var clue_menu_button_pscn: PackedScene = preload("res://assets/prefabs/ui_menu/buttons/clue_menu_button.tscn")

var clue_cache: Array[ClueData] = []

var has_reward: bool = false
var rewards_info: Array[Dictionary] = []
var current_reward_info: Dictionary = {}

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

func is_clue_area_valid(area: ClueArea) -> bool:
	if !area:
		push_error("Clue area is null!")
		return false
	if !is_instance_valid(area):
		push_error("Clue area is invalid!")
		return false
	if !area.is_inside_tree():
		push_error("Clue area is not in tree!")
		return false
	return true

func unlock_reward(clue_id: String) -> Dictionary:
	var cd: ClueData = get_clue_data_by_id(clue_id)

	# check if reward is another clue
	var reward_cd: ClueData = get_clue_data_by_id(cd.get_clue().reward_id)
	if reward_cd and reward_cd.get_clue().status == ClueState.ClueStatus.HIDDEN:
		reward_cd.set_clue_status(ClueState.ClueStatus.ACTIVE)
		reward_cd.set_clue_area_monitorable(true)
		return {
			"reward_id": reward_cd.get_clue().id,
			"type": 'clue',
			"string": reward_cd.get_clue().title
		}
	
	# check if reward is a collectible
	var reward_clld: CollectibleData = CollectibleState.get_collectible_data_by_id(cd.get_clue().reward_id)
	if reward_clld and reward_clld.get_collectible().status == CollectibleState.CollectibleStatus.UNOBTAINED:
		reward_clld.set_collectible_status(CollectibleState.CollectibleStatus.OBTAINED)
		return {
			"reward_id": reward_clld.get_collectible().id,
			"type": 'collectible',
			"string": reward_clld.get_collectible().title
		}

	return {}

func update_current_reward_info() -> void:
	var reward_info: Variant = rewards_info.pop_front()
	current_reward_info = {} if reward_info == null else reward_info

func change_clue_status(id: String, new_status: ClueStatus) -> void:
	var cd: ClueData = get_clue_data_by_id(id)
	cd.set_clue_status(new_status)

func get_clues(filters: Dictionary) -> Array[ClueData]:
	# example filter:
	# { 'status': 'ClueStatus.HIDDEN' }

	var result: Array[ClueData] = clue_cache
	for key: String in filters.keys():
		result = result.filter(
			func(cd: ClueData) -> bool:
				return (cd as ClueData).get_clue().get(key) == filters[key]
		)
	return result

func get_clue_data_by_id(clue_id: String) -> ClueData:
	var cd: Array[ClueData] = clue_cache.filter(
		func(_cd: ClueData) -> bool:
			return _cd.get_clue().id == clue_id
	)
	if cd.is_empty(): return null
	return cd[0]

func get_clue_data_by_area(clue_area: ClueArea) -> ClueData:
	var cd: Array[ClueData] = clue_cache.filter(
		func(_cd: ClueData) -> bool:
			return _cd.get_clue_area() == clue_area
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
	(clue_menu_button as GenericButton).args = [{ "clue_id": clue.id, 'is_confirmation': false }]

	clue_cache.append(ClueData.new(clue, clue_menu_button))
