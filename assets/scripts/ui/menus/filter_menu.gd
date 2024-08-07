class_name FilterMenu extends BaseMenu

@export_group("References")
@export var filter_container: GridContainer

func _ready() -> void:
	super()
	assert(filter_container)

func _mount_filter_buttons() -> void:
	for fd: Dictionary in GeotagState.all_filters:
		var btn: GenericToggleButton = fd['button']
		filter_container.add_child.call_deferred(btn)

func _unmount_filter_buttons() -> void:
	for btn: Node in filter_container.get_children():
		filter_container.remove_child.call_deferred(btn)

func after_entering() -> void:
	_mount_filter_buttons()
	await super()
	(filter_container.get_child(0) as GenericToggleButton).grab_focus()

func about_to_exit() -> void:
	await super()
	_unmount_filter_buttons()