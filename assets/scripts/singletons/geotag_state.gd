extends Node

var all_filters: Array[Dictionary] = []
var active_filters: Array[Dictionary] = []

const FILTER_TOGGLE_BUTTON_PSCN: PackedScene = preload("res://assets/prefabs/ui_menu/buttons/generic_toggle_button.tscn")

# region Filter

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
	var toggle_btn: GenericToggleButton = FILTER_TOGGLE_BUTTON_PSCN.instantiate()
	(toggle_btn as GenericToggleButton).args = [geotag_data['id']]
	(toggle_btn as GenericToggleButton).text = get_geotag_name(geotag_data['id'])
	return { 
		"geotag_id": geotag_data['id'],
		'button': toggle_btn
	}

# region Geotag

## Get an array of all geotags (which indcludes all sundial managers).
## Dictionary looks like this: { "id": [value], "name": [value] }
func get_all_geotags() -> Array[Dictionary]:
	var tags: Array[Dictionary] = [{
		"id": "none",
		"name": "Uncategorized"
	}]

	for lsm: Node in State.sundial_groups['local_sundial_managers']:
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

	for lsm: Node in State.sundial_groups['local_sundial_managers']:
		if !(lsm is LocalSundialManager): continue
		if !(lsm as LocalSundialManager).first_marker_done: continue
		available_tags.append((lsm as LocalSundialManager).get_geotag_data())

	for wp: Node in State.waypoint_markers:
		if !(wp is WaypointMarker): continue
		available_tags.append((wp as WaypointMarker).get_geotag_data())

	return available_tags

## Get the geotag name based on the geotag id.
func get_geotag_name(id: String) -> String:
	var tags: Array[Dictionary] = get_all_geotags()

	var td: Array[Dictionary] = tags.filter(
		func(data: Dictionary) -> bool:
			return data["id"] == id
	)

	if td.is_empty(): return ""
	return (td[0] as Dictionary)['name']

func create_geotag_menu_label(label_text: String) -> Label:
	var label: Label = Label.new()
	label.text = label_text
	return label