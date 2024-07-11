extends Node

const PICTURE_FOLDER_PATH: String = "res://assets/resources/pictures/"
const PICTURE_UNCATEGORIZED_FOLDER: String = "uncategorized/"

var filter_toggle_button_pscn: PackedScene = preload("res://assets/prefabs/user_interfaces/buttons/generic_toggle_button.tscn")
var all_filters: Array[Dictionary] = []
var active_filters: Array[Dictionary] = []

var picture_button_pscn: PackedScene = preload("res://assets/prefabs/user_interfaces/buttons/picture_button.tscn")
var picture_toggle_button_pscn: PackedScene = preload("res://assets/prefabs/user_interfaces/buttons/picture_toggle_button.tscn")
var picture_cache: Array[PictureData] = []
var pictures_to_delete: Array[Picture] = []

var pictures_to_be_geotagged: Array[Picture] = []

func _ready() -> void:
	load_pictures()

func _exit_tree() -> void:
	print("exit")

## Load pictures from the pictures folder and create cache of it.
func load_pictures() -> void:
	var dir: DirAccess = DirAccess.open(PICTURE_FOLDER_PATH)
	if !dir:
		push_error("Cannot load files!") 
		return

	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	while file_name != "":
		if !dir.current_is_dir():
			var picture: Picture = load(PICTURE_FOLDER_PATH + file_name)
			create_picture_cache(picture)
		file_name = dir.get_next()

func save_pictures() -> void:
	for pd: PictureData in picture_cache:
		var pic: Picture = pd.get_picture()
		ResourceSaver.save(pic)

	for pic: Picture in pictures_to_delete:
		DirAccess.remove_absolute(pic.resource_path)

## Adds an filter to the active filter array.
func add_active_filter(fd: Dictionary) -> void:
	if !active_filters.has(fd):
		active_filters.append(fd)

## Removes an active filter.
func remove_active_filter(fd: Dictionary) -> void:
	if active_filters.has(fd):
		active_filters.erase(fd)

## Returns a single filter data based on the [geotag_id].
func get_filter(geotag_id: String) -> Dictionary:
	var filtered_fd: Array[Dictionary] = all_filters.filter(
		func(_fd: Dictionary) -> bool:
			return _fd['geotag_id'] == geotag_id
	)
	if filtered_fd.is_empty(): return {}
	return filtered_fd[0]

func remove_filter(fd: Dictionary) -> void:
	all_filters.erase(fd)

## update the [all_filters] array.
func load_all_filters() -> void:
	var available_geotags: Array[Dictionary] = get_available_geotags()

	for geotag_data: Dictionary in available_geotags:
		var current_filter: Array[Dictionary] = all_filters.filter(
			func(fd: Dictionary) -> bool:
				return fd['geotag_id'] == geotag_data['id']
		)

		# If filter has been created before, continue
		if !current_filter.is_empty(): continue

		var new_fd: Dictionary = create_filter_data(geotag_data)
		all_filters.append(new_fd)

## Creates a new filter data based on the geotag data.
func create_filter_data(geotag_data: Dictionary) -> Dictionary:
	var toggle_btn: GenericToggleButton = filter_toggle_button_pscn.instantiate()
	(toggle_btn as GenericToggleButton).args = [geotag_data['id']]
	(toggle_btn as GenericToggleButton).text = get_geotag_name(geotag_data['id'])
	return { 
		"geotag_id": geotag_data['id'],
		'button': toggle_btn
	}

## Get the geotag name based on the geotag id.
func get_geotag_name(id: String) -> String:
	var tags: Array[Dictionary] = get_all_geotags()

	var td: Array[Dictionary] = tags.filter(
		func(data: Dictionary) -> bool:
			return data["id"] == id
	)

	if td.is_empty(): return ""
	return (td[0] as Dictionary)['name']

## Get an array of all geotags (which indcludes all sundial managers).
## Dictionary looks like this: { "id": [value], "name": [value] }
func get_all_geotags() -> Array[Dictionary]:
	var tags: Array[Dictionary] = [{
		"id": "none",
		"name": "Uncategorized"
	}]

	for lsm: Node in State.local_sundials:
		if !(lsm is LocalSundialManager): continue
		tags.append((lsm as LocalSundialManager).get_geotag_data())

	for wp: Node in State.waypoint_markers:
		if !(wp is WaypointMarker): continue
		tags.append((wp as WaypointMarker).get_geotag_data())

	return tags

## Get an array of available geotags (which includes all local sundial managers that has first_marker_done set as true).
## Dictionary looks like this: { "id": [value], "name": [value] }
func get_available_geotags() -> Array[Dictionary]:
	var available_tags: Array[Dictionary] = [{
		"id": "none",
		"name": "Uncategorized"
	}]

	for lsm: Node in State.local_sundials:
		if !(lsm is LocalSundialManager): continue
		if !(lsm as LocalSundialManager).first_marker_done: continue
		available_tags.append((lsm as LocalSundialManager).get_geotag_data())

	for wp: Node in State.waypoint_markers:
		if !(wp is WaypointMarker): continue
		available_tags.append((wp as WaypointMarker).get_geotag_data())

	return available_tags

func get_clue_pictures(clue_id: String) -> Array[PictureData]:
	var clue_pics: Array[PictureData] = picture_cache.filter(
		func(pd: PictureData) -> bool:
			return pd.get_picture().clue_id == clue_id
	)

	return clue_pics

## Get pictures from the cache, filtered based on the [filter] parameter.
func get_filtered_pictures(filter: Array[Dictionary]) -> Array[PictureData]:
	var no_clue_pics: Array[PictureData] = picture_cache.filter(
		func(pd: PictureData) -> bool:
			return pd.get_picture().clue_id == "none"
	)

	if filter.is_empty():
		return no_clue_pics

	var active_filter_tag_id: Array = filter.map(
		func(fd: Dictionary) -> String:
			return fd['geotag_id']
	)
	var filtered_pics: Array[PictureData] = no_clue_pics.filter(
		func(pd: PictureData) -> bool:
			return active_filter_tag_id.has(pd.get_picture().geotag_id)
	)

	return filtered_pics

## Creates a new picture cache.
func create_picture_cache(picture: Picture) -> void:
	# see if we have this resource inside the cache already.
	var existing_picture: Array[PictureData] = picture_cache.filter(
		func(_pd: PictureData) -> bool:
			return _pd.get_picture().resource_path == picture.resource_path
	)
	
	# if we have the picture resource inside the cache, return
	if !existing_picture.is_empty():
		return

	# create a new button and picture
	var pic_button: PictureButton = picture_button_pscn.instantiate()
	(pic_button as PictureButton).assigned_picture = picture

	var pic_toggle: PictureToggleButton = picture_toggle_button_pscn.instantiate()
	(pic_toggle as PictureToggleButton).assigned_picture = picture

	# add to cache
	picture_cache.append(PictureData.new(picture, pic_button, pic_toggle))

## Remove a specific picture from the cache.
func remove_picture_cache(picture: Picture) -> void:
	var existing_picture: Array[PictureData] = picture_cache.filter(
		func(_pd: PictureData) -> bool:
			return _pd.get_picture().resource_path == picture.resource_path
	)
	
	# No file found in cache, returning
	if existing_picture.is_empty():
		return

	# Remove from cache and delete the picture button (if any)
	var existing_pd: PictureData = existing_picture[0]
	if existing_pd.get_picture_button():
		existing_pd.get_picture_button().queue_free()
	if existing_pd.get_picture_toggle_button():
		existing_pd.get_picture_toggle_button().queue_free()
	picture_cache.erase(existing_pd)
