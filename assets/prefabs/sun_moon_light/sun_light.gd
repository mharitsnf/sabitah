class_name SunLight extends SunMoonLight

func _enter_tree() -> void:
    match level_type:
        State.LevelType.MAIN:
            if !State.game_sun: State.game_sun = self
        State.LevelType.GLOBE:
            if !State.globe_sun: State.globe_sun = self