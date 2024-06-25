class_name GlobeHUDLayer extends HUDLayer

@export_group("References")
@export var lat_label: Label
@export var long_label: Label

func _ready() -> void:
	assert(lat_label)
	assert(long_label)

func set_lat_long_text(lat: float, long: float) -> void:
	lat_label.text = str(lat)
	long_label.text = str(long)
