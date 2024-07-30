class_name PlayerMainCamera extends MainCamera

@export var level_type: State.LevelType

func _enter_tree() -> void:
	match level_type:
		State.LevelType.MAIN: State.game_camera = self
		State.LevelType.GLOBE: State.globe_camera = self

func _ready() -> void:
	super()
	
func _process(delta: float) -> void:
	super(delta)
	if current_follow_data:
		current_follow_data.get_target().player_input_process(delta)

func _physics_process(delta: float) -> void:
	if current_follow_data:
		current_follow_data.get_target().delegated_physics_process(delta)

func _unhandled_input(event: InputEvent) -> void:
	if current_follow_data:
		current_follow_data.get_target().player_unhandled_input(event)

func _on_old_target_removed(old_camera: VirtualCamera) -> void:
	var hud_layer: HUDLayer = Group.first("hud_layer")
	if old_camera is FirstPersonCamera:
		if hud_layer is GameHUDLayer:
			hud_layer.hide_crosshair()

func _on_follow_target_changed(new_camera: VirtualCamera) -> void:
	var hud_layer: HUDLayer = Group.first("hud_layer")
	if new_camera is BoatFirstPersonCamera:
		if hud_layer is GameHUDLayer:
			hud_layer.show_crosshair()