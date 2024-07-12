class_name StarManager extends Node

const FOLDER_PATH : String = "res://assets/resources/starmaps/"
const FILE_EXTENSION : String = ".smap"

@export var starmap_filename : String
@export var use_background_star : bool = true
@export_group("Main star settings")
@export var game_main_star_pscn : PackedScene
@export var globe_main_star_pscn : PackedScene
@export_group("Background star settings")
@export var background_star_pscn : PackedScene
@export var background_star_amount : int = 1000

var main_stars: Array[StarData] = []
var background_stars: Array[StarData] = []

signal stars_loaded(type: State.StarType)

func _ready() -> void:
	_load_main_stars()
	if use_background_star:
		_load_background_stars()

func _load_main_stars() -> void:
	var starmap_file : FileAccess = FileAccess.open(FOLDER_PATH + starmap_filename + FILE_EXTENSION, FileAccess.READ)
	while starmap_file.get_position() < starmap_file.get_length():
		var json_string : String = starmap_file.get_line()
		var json : JSON = JSON.new()

		var parse_result : int = json.parse(json_string)
		if parse_result != OK:
			printerr("JSON parse error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue
		
		var game_main_star_data : Dictionary = json.get_data()
		var main_planet_data: Dictionary = State.get_planet_data(State.LevelType.MAIN)
		game_main_star_data['distance_from_center'] = main_planet_data['star_distance']
		game_main_star_data['level_type'] = State.LevelType.MAIN
		var game_inst: MainStar = game_main_star_pscn.instantiate()
		game_inst.data = game_main_star_data

		var globe_main_star_data: Dictionary = game_main_star_data.duplicate()
		var globe_planet_data: Dictionary = State.get_planet_data(State.LevelType.GLOBE)
		globe_main_star_data['distance_from_center'] = globe_planet_data['star_distance'] * .4
		globe_main_star_data['level_type'] = State.LevelType.GLOBE
		var globe_inst: MainStar = globe_main_star_pscn.instantiate()
		globe_inst.data = globe_main_star_data

		main_stars.append(StarData.new(game_inst, globe_inst))
	
	stars_loaded.emit(State.StarType.MAIN)

func _load_background_stars() -> void:
	for i : int in range(background_star_amount):
		var dir : Vector3 = Vector3(randf() * 2. - 1, randf() * 2. - 1., randf() * 2. - 1.).normalized()
		var star_inst : BackgroundStar = background_star_pscn.instantiate()
		star_inst.data = {
			"global_position": dir * (State.PLANET_RADIUS * State.STAR_RADIUS_SCALE)
		}
		background_stars.append(StarData.new(star_inst))
	
	stars_loaded.emit(State.StarType.BACKGROUND)
