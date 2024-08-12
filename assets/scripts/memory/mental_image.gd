class_name MentalImage extends Resource

@export var id: String
@export var memory_id: String = ""
@export var image_tex: Texture2D
@export var speaker: String = ""
@export_multiline var thoughts: String = ""
@export var is_the_past: bool = false

func get_thoughts() -> String:
	var res: String = thoughts
	if is_the_past:
		res = "[color=KHAKI][i]" + thoughts + "[/i][/color]"
	return res