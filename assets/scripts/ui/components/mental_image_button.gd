class_name MentalImageButton extends GenericButton

@export var speaker_label: Label
@export var thoughts_label: RichTextLabel
@export var texture_rect: TextureRect

func _ready() -> void:
	assert(speaker_label)
	assert(thoughts_label)
	assert(texture_rect)