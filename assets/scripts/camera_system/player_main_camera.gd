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

func _unhandled_input(event: InputEvent) -> void:
    if current_follow_data:
        current_follow_data.get_target().player_unhandled_input(event)