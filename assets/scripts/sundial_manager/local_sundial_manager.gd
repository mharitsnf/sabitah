class_name LocalSundialManager extends SundialManager

@export var island_name: String = "Primarina Island"
var island_alias: String = ""

var first_marker_done: bool = false
var second_marker_done: bool = false

func _ready() -> void:
	super()
	_assign_island_alias()

func _assign_island_alias() -> void:
	var latlong: Array = Common.Geometry.point_to_latlng(global_position.normalized())
	island_alias = State.create_picture_tag(latlong[0], latlong[1])

func get_island_name() -> String:
	if second_marker_done:
		return island_name
	return island_alias