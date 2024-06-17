class_name PlayerMainCamera extends MainCamera


func _process(delta: float) -> void:
    super(delta)
    if current_follow_data:
        current_follow_data.get_target().player_input_process(delta)

func _unhandled_input(event: InputEvent) -> void:
    if current_follow_data:
        current_follow_data.get_target().player_unhandled_input(event)