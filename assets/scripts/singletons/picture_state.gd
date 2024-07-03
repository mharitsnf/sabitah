extends Node

var filter_toggle_button_pscn: PackedScene = preload("res://assets/prefabs/user_interfaces/buttons/generic_toggle_button.tscn")
var all_filters: Array[FilterData] = []
var active_filters: Array[FilterData] = []

var picture_button_pscn: PackedScene = preload("res://assets/prefabs/user_interfaces/buttons/picture_button.tscn")
var picture_cache: Array[PictureData] = []

signal active_filter_added(filter_data: FilterData)
signal active_filter_removed(filter_data: FilterData)

func _ready() -> void:
	update_gallery_filters()
	load_pictures()

func add_active_filter(fd: FilterData) -> void:
	if !active_filters.has(fd):
		active_filters.append(fd)
		active_filter_added.emit(fd)

func remove_active_filter(fd: FilterData) -> void:
	if active_filters.has(fd):
		active_filters.erase(fd)
		active_filter_removed.emit(fd)

func get_filter_data(geotag_id: String) -> FilterData:
	var filtered_fd: Array[FilterData] = all_filters.filter(
		func(_fd: FilterData) -> bool:
			return _fd.get_geotag_id() == geotag_id
	)
	if filtered_fd.is_empty(): return null
	return filtered_fd[0]

func update_gallery_filters() -> void:
	var available_tags: Array[Dictionary] = get_available_geotags()

	for geotag_data: Dictionary in available_tags:
		var current_filter: Array[FilterData] = all_filters.filter(
			func(fd: FilterData) -> bool:
				return fd.get_geotag_id() == geotag_data['id']
		)

		# If filter has been created before, continue
		if !current_filter.is_empty(): continue

		var new_fd: FilterData = create_filter_data(geotag_data)
		all_filters.append(new_fd)

func create_filter_data(geotag_data: Dictionary) -> FilterData:
	var new_fd: FilterData = FilterData.new(geotag_data['id'])
	var toggle_btn: GenericToggleButton = filter_toggle_button_pscn.instantiate()
	(toggle_btn as GenericToggleButton).args = [geotag_data['id']]
	(toggle_btn as GenericToggleButton).text = get_geotag_name(geotag_data['id'])
	new_fd.set_button(toggle_btn)
	return new_fd

func get_geotag_name(id: String) -> String:
	var tags: Array[Dictionary] = get_geotags()

	var td: Array[Dictionary] = tags.filter(
		func(data: Dictionary) -> bool:
			return data["id"] == id
	)

	if td.is_empty(): return ""
	return (td[0] as Dictionary)['name']

func get_geotags() -> Array[Dictionary]:
	var tags: Array[Dictionary] = [{
		"id": "none",
		"name": "Uncategorized"
	}]

	for lsm: Node in Group.all("local_sundial_managers"):
		if !(lsm is LocalSundialManager): continue
		tags.append((lsm as LocalSundialManager).get_island_tag_data())

	return tags

func get_available_geotags() -> Array[Dictionary]:
	var available_tags: Array[Dictionary] = [{
		"id": "none",
		"name": "Uncategorized"
	}]

	for lsm: Node in Group.all("local_sundial_managers"):
		if !(lsm is LocalSundialManager): continue
		if !(lsm as LocalSundialManager).first_marker_done: continue
		available_tags.append((lsm as LocalSundialManager).get_island_tag_data())

	return available_tags

func get_pictures_data(filter: Array[FilterData]) -> Array[PictureData]:
	if filter.is_empty():
		return picture_cache

	var active_filter_tag_id: Array = filter.map(
		func(fd: FilterData) -> String:
			return fd.get_geotag_id()
	)
	var filtered_picture_cache: Array[PictureData] = picture_cache.filter(
		func(pd: PictureData) -> bool:
			return active_filter_tag_id.has(pd.get_picture().geotag_id)
	)

	return filtered_picture_cache

## Load pictures from the pictures folder and create cache of it.
func load_pictures() -> void:
	var dir: DirAccess = DirAccess.open(State.PICTURE_FOLDER_PATH)
	if !dir:
		push_error("Cannot load files!") 
		return

	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	while file_name != "":
		if !dir.current_is_dir():
			create_picture_cache(State.PICTURE_FOLDER_PATH + file_name)
		file_name = dir.get_next()

func create_picture_cache(resource_path: String) -> void:
	# see if we have this resource inside the cache already.
	var existing_picture: Array[PictureData] = picture_cache.filter(
		func(_pd: PictureData) -> bool:
			return _pd.get_picture().resource_path == resource_path
	)
	
	# if we have the picture resource inside the cache, return
	if !existing_picture.is_empty():
		return

	# create a new button and picture
	var pic: Resource = load(resource_path)
	var pic_button: PictureButton = picture_button_pscn.instantiate()
	(pic_button as PictureButton).assigned_picture = pic

	# add to cache
	picture_cache.append(PictureData.new(pic, pic_button))

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
	picture_cache.erase(existing_pd)

## Look for Picture files that have been deleted inside [picture_cache], and then remove them from the cache.
func remove_invalid_caches() -> void:
	var to_be_erased: Array[PictureData] = []
	
	for pd: PictureData in picture_cache:
		var exists: bool = FileAccess.file_exists(pd.get_picture().resource_path)
		if !exists: to_be_erased.append(pd)
	
	for epd: PictureData in to_be_erased:
		if epd.get_picture_button(): epd.get_picture_button().queue_free()
		picture_cache.erase(epd)