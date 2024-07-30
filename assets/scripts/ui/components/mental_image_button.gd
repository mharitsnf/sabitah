class_name MentalImageButton extends GenericButton

@export var description_label: Label
@export var texture_rect: TextureRect

func _ready() -> void:
	assert(description_label)
	assert(texture_rect)