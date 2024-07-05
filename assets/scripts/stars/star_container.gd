class_name StarContainer extends Node3D

@export var level_type: State.LevelType
@export var container_type: State.StarType

var star_manager: StarManager

func _enter_tree() -> void:
	star_manager = Group.first("star_manager")
	assert(star_manager)

func _ready() -> void:
	load_stars(container_type)

func load_stars(star_type: State.StarType) -> void:
	if container_type != star_type: return

	var stars: Array[StarData] = star_manager.main_stars if star_type == State.StarType.MAIN else star_manager.background_stars
	for sd: StarData in stars:
		var instance: Node = sd.get_game_instance() if level_type == State.LevelType.MAIN else sd.get_globe_instance()
		add_child.call_deferred(instance)