class_name CollectiblesMenu extends BaseMenu

@export var buttons_container: GridContainer

func _ready() -> void:
	super()
	assert(buttons_container)

func _mount_collectible_menu_buttons() -> void:
	var collectibles: Array[CollectibleData] = CollectibleState.get_collectibles({ 'status': CollectibleState.CollectibleStatus.UNOBTAINED })
	for cd: CollectibleData in collectibles:
		var menu_button: GenericButton = cd.get_menu_button()
		buttons_container.add_child.call_deferred(menu_button)

func _unmount_collectible_menu_buttons() -> void:
	for c: Node in buttons_container.get_children():
		buttons_container.remove_child.call_deferred(c)

func about_to_exit() -> void:
	await super()
	_unmount_collectible_menu_buttons()

# Overridden
func after_entering() -> void:
	_mount_collectible_menu_buttons()
	await super()

	if buttons_container.get_child_count() > 0:
		(buttons_container.get_child(0) as GenericButton).grab_focus()