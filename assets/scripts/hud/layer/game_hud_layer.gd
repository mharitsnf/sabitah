class_name GameHUDLayer extends HUDLayer

@export var time_label: Label
@export var anim: AnimationPlayer

var time_manager: TimeManager

var time_container_shown: bool = false

func _ready() -> void:
	time_manager = Group.first("time_manager")

	assert(time_label)
	assert(anim)
	assert(time_manager)

func _process(_delta: float) -> void:
	var time_data: Array = time_manager.get_game_time()
	time_label.text = time_data[0] + ":" + time_data[1]

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
