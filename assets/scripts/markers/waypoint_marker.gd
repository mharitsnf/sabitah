class_name WaypointMarker extends GlobeMarker

var waypoint_name: String
var geotag_id: String

func _ready() -> void:
	State.waypoint_markers.append(self)
	_assign_geotag_id()
	_assign_waypoint_name()
	GeotagState.load_all_filters()

func destroy() -> void:
	var fd_none: Dictionary = GeotagState.get_filter("none")
	var fd: Dictionary = GeotagState.get_filter(geotag_id)

	# get pictures that has the current geotag and assign none to it
	var pictures: Array[PictureData] = PictureState.get_pictures({ 'geotag_id': fd['geotag_id'] })
	for pic: PictureData in pictures:
		pic.get_picture().geotag_id = fd_none.geotag_id

	# remove the filter from the state
	GeotagState.remove_filter(fd)
	if GeotagState.active_filters.has(fd): GeotagState.active_filters.erase(fd)
	
	# remove the waypoint marker
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