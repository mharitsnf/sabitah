class_name Gallery extends BaseMenu

@export_group("References")
@export var picture_button_container: GridContainer
@export var add_filter_button: GenericButton
@export var picture_button_pscn: PackedScene

var picture_cache: Array[PictureData] = []

var prev_focused_button: Button
var focused_button: Button

func _ready() -> void:
	super()
	assert(picture_button_container)
	assert(add_filter_button)
	assert(picture_button_pscn)

	add_filter_button.focus_entered.connect(_on_button_focused.bind(add_filter_button))

func _enter_tree() -> void:
	# wait for the picture container to be loaded,
	# remove deleted pictures and add new pictures.
	await picture_button_container.tree_entered
	_remove_deleted_pictures()
	_load_pictures()

# func _input(event: InputEvent) -> void:
# 	super(event)
# 	if event.is_action_pressed("delete_picture"):
# 		if !(focused_button is PictureButton): return
# 		_delete_picture((focused_button as PictureButton).assigned_picture)

func _delete_picture(picture: Picture) -> void:
	DirAccess.remove_absolute(picture.resource_path)
	_remove_deleted_pictures()
	prev_focused_button.grab_focus()

## Private. Remove data from cache if the resource referenced in the cache
## has been deleted.
func _remove_deleted_pictures() -> void:
	var to_be_erased: Array[PictureData] = []
	
	for pd: PictureData in picture_cache:
		var exists: bool = FileAccess.file_exists(pd.get_picture().resource_path)
		if !exists: to_be_erased.append(pd)
	
	for epd: PictureData in to_be_erased:
		epd.get_picture_button().queue_free()
		picture_cache.erase(epd)

## Private. Load pictures from the picture directory.
func _load_pictures() -> void:
	var dir: DirAccess = DirAccess.open(State.PICTURE_FOLDER_PATH)
	if !dir:
		push_error("Cannot load files!") 
		return

	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	while file_name != "":
		if !dir.current_is_dir():
			_create_picture_button(State.PICTURE_FOLDER_PATH + file_name)
		file_name = dir.get_next()

## Private. Create picture button of the picture with path [resource_path], and add that
## picture to cache.
func _create_picture_button(resource_path: String) -> void:
	# see if we have this resource inside the cache already.
	var existing_picture: Array[PictureData] = picture_cache.filter(
		func(_pd: PictureData) -> bool:
			return _pd.get_picture().resource_path == resource_path
	)
	
	# if we have the picture resource inside the cache, return
	if !existing_picture.is_empty():
		return

	# create a new button and picture
	var pic_button: PictureButton = picture_button_pscn.instantiate()
	var pic: Resource = load(resource_path)
	(pic_button as PictureButton).assigned_picture = pic as Picture

	# add to cache
	picture_cache.append(PictureData.new(pic, pic_button))

	(pic_button as PictureButton).focus_entered.connect(_on_button_focused.bind(pic_button))

	# add button to container
	picture_button_container.add_child.call_deferred(pic_button)


func _on_button_focused(btn: Button) -> void:
	if focused_button:
		prev_focused_button = focused_button

	focused_button = btn

# Overridden
func about_to_exit() -> void:
	await super()
	add_filter_button.release_focus()

# Overridden
func after_entering() -> void:
	await super()
	add_filter_button.grab_focus()