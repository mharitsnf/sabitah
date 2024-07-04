class_name WaypointMarker extends GlobeMarker

var waypoint_name: String
var geotag_id: String

func _ready() -> void:
	State.waypoint_markers.append(self)
	_assign_geotag_id()
	_assign_waypoint_name()
	PictureState.update_all_filters()
	print(PictureState.all_filters)

func destroy() -> void:
	State.waypoint_markers.erase(self)
	queue_free()

## Create island tag (called on ready).
func _assign_geotag_id() -> void:
	var latlong: Array = Common.Geometry.point_to_latlng(global_position.normalized())
	geotag_id = "w(" + str(latlong[0]) + "," + str(latlong[1]) + ")"

## Create island alias (called on ready).
func _assign_waypoint_name() -> void:
	var latlong: Array = Common.Geometry.point_to_latlng(global_position.normalized())
	waypoint_name = str(latlong[0]) + "°N, " + str(latlong[1]) + "°S Waypoint"

func get_geotag_data() -> Dictionary:
	return {
		"id": geotag_id,
		"name": waypoint_name
	}