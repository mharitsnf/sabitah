class_name IslandSearch extends LatLongSearch

@export_group("References")
@export var level_anim: AnimationPlayer

func _ready() -> void:
	super()
	assert(level_anim)

func player_input_process(delta: float) -> void:
	super(delta)
	_get_select_location_input()

func _get_select_location_input() -> void:
	if Input.is_action_just_pressed("select_location_on_globe"):
		print("location: ", query_res)