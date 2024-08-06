class_name MemoriesMenu extends BaseMenu

@export var change_filter_button: GenericButton
@export var menu_header_label: Label
@export var menu_button_container: GridContainer
@export var filter_tag_container: GridContainer

func _mount_menu_buttons() -> void:
	# get memories to show
	var memories_to_show: Array[MemoryData] = []
	if !GeotagState.active_filters.is_empty():
		for filter: Dictionary in GeotagState.active_filters:
			memories_to_show += MemoryState.get_memories({ "locked_status": Memory.LockedStatus.UNLOCKED, "geotag_id": filter['geotag_id'] })
	else:
		memories_to_show = MemoryState.get_memories({ "locked_status": Memory.LockedStatus.UNLOCKED })

	for md: MemoryData in memories_to_show:
		var menu_button: GenericButton = md.get_menu_button()
		menu_button_container.add_child.call_deferred(menu_button)

func _unmount_menu_buttons() -> void:
	for c: Node in menu_button_container.get_children():
		menu_button_container.remove_child.call_deferred(c)

func _mount_active_filter_labels() -> void:
	if GeotagState.active_filters.is_empty():
		var tag_label: Label = GeotagState.create_geotag_menu_label("Show All")
		filter_tag_container.add_child.call_deferred(tag_label)
		return

	for pd: Dictionary in GeotagState.active_filters:
		var tag_name: String = GeotagState.get_geotag_name(pd['geotag_id'])
		var tag_label: Label = GeotagState.create_geotag_menu_label(tag_name)
		filter_tag_container.add_child.call_deferred(tag_label)

func _unmount_active_filter_labels() -> void:
	for label: Node in filter_tag_container.get_children():
		filter_tag_container.remove_child.call_deferred(label)

func about_to_exit() -> void:
	await super()
	_unmount_menu_buttons()
	_unmount_active_filter_labels()

# Overridden
func after_entering() -> void:
	_mount_menu_buttons()
	_mount_active_filter_labels()
	await super()
	change_filter_button.grab_focus()