class_name GlobeHUDLayer extends HUDLayer

@export_group("References")
@export var anim: AnimationPlayer
@export var instruction_label: Label
@export var lat_label: Label
@export var long_label: Label

func _ready() -> void:
	assert(anim)
	assert(instruction_label)
	assert(lat_label)
	assert(long_label)

func set_lat_long_text(lat: float, long: float) -> void:
	lat_label.text = str(lat)
	long_label.text = str(long)

func reset_animation() -> void:
	anim.play("RESET")

func set_instruction_text(text: String, status: Common.Status = Common.Status.NONE) -> void:
	instruction_label.text = text

	match status:
		Common.Status.SUCCESS:
			anim.play("show_success_status")
			await anim.animation_finished
		Common.Status.ERROR:
			anim.play("show_error_status")
			await anim.animation_finished

func reset_instruction_text() -> void:
	instruction_label.text = "Press [LMB] to confirm your selection."

func show_instruction_panel() -> void:
	anim.play("show_instruction_panel")
	await anim.animation_finished

func hide_instruction_panel() -> void:
	anim.play("hide_instruction_panel")
	await anim.animation_finished