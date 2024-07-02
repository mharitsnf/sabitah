class_name LocalSundialManager extends SundialManager

@export var island_name: String = "Primarina Island"
var island_alias: String = ""
var island_tag: String = ""

var first_marker_done: bool = false
var second_marker_done: bool = false

func _ready() -> void:
	super()
	_create_island_tag()
	_assign_island_alias()

func _create_island_tag() -> void:
	var latlong: Array = Common.Geometry.point_to_latlng(global_position.normalized())
	island_tag = "(" + str(latlong[0]) + "," + str(latlong[1]) + ")"

func _assign_island_alias() -> void:
	var latlong: Array = Common.Geometry.point_to_latlng(global_position.normalized())
	island_alias = State.get_island_lat_long_name(latlong[0], latlong[1])

func get_island_tag_data() -> Dictionary:
	return {
		"id": island_tag,
		"name": get_island_name()
	}

func get_island_name() -> String:
	if second_marker_done:
		return island_name
	return island_alias