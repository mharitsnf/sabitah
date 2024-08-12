class_name GameHUDLayer extends HUDLayer

@export var notification_label: Label
@export var time_label: Label
@export var island_name_label: Label
@export var height_angle_label: Label
@export var anim: AnimationPlayer
@export var notes_label: Label

var time_manager: TimeManager

var time_container_shown: bool = false
var crosshair_shown: bool = false

func _ready() -> void:
	super()
	time_manager = Group.first("time_manager")

	assert(notification_label)
	assert(time_label)
	assert(anim)
	assert(time_manager)

func _process(_delta: float) -> void:
	var time_data: Array = time_manager.get_game_time()
	time_label.text = time_data[0] + ":" + time_data[1]

func set_island_name_label_text(value: String) -> void:
	island_name_label.text = value

func set_notification_text(value: String) -> void:
	notification_label.text = value

func show_crosshair() -> void:
	if !crosshair_shown:
		anim.play("show_crosshair")
		crosshair_shown = true

func set_height_angle_text(value: String) -> void:
	height_angle_label.text = value

func hide_crosshair() -> void:
	if crosshair_shown:
		anim.play("hide_crosshair")
		crosshair_shown = false

func show_notification() -> void:
	anim.play("show_notification")
	# no await because used in dialogue

func show_island_name() -> void:
	anim.play("show_island_name")
	await anim.animation_finished

func take_picture_screen() -> void:
	anim.play("take_picture_screen")
	await anim.animation_finished

func show_time_container() -> void:
	if !time_container_shown:
		anim.play("show_time_container")
		await anim.animation_finished
		time_container_shown = true

func hide_time_container() -> void:
	if time_container_shown:
		anim.play("hide_time_container")
		await anim.animation_finished
		time_container_shown = false

func set_notes_label_text(value: String) -> void:
	notes_label.text = value

func show_notes_label() -> void:
	if !notes_label.visible:
		notes_label.visible = true

func hide_notes_label() -> void:
	if notes_label.visible:
		notes_label.visible = false
