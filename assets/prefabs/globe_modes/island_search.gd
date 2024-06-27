class_name IslandSearch extends LatLongSearch

@export_group("References")
@export var level_anim: AnimationPlayer

func _ready() -> void:
	super()

	assert(level_anim)