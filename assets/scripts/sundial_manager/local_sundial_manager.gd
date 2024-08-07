class_name LocalSundialManager extends SundialManager

@export var island_name: String = "Primarina Island"
@export var boat_waypoint: Marker3D
var latlong: Array
var island_alias: String = ""
var geotag_id: String = ""

var first_marker_done: bool = false
var second_marker_done: bool = false

func _ready() -> void:
	super()

	assert(boat_waypoint)

	# add sundial to state groups
	for group: StringName in get_groups():
		if str(group).begins_with("_"): continue
		if !State.sundial_groups.has(str(group)):
			State.sundial_groups[str(group)] = []
		State.sundial_groups[str(group)].append(self)

	latlong = Common.Geometry.point_to_latlng(global_position.normalized())
	print(latlong)
	geotag_id = "i(" + str(latlong[0]) + "," + str(latlong[1]) + ")"
	island_alias = str(latlong[0]) + "°N, " + str(latlong[1]) + "°S Island"

func get_geotag_data() -> Dictionary:
	return {
		"id": geotag_id,
		"name": get_island_name()
	}

func get_island_name() -> String:
	if second_marker_done:
		return island_name
	return island_alias
