class_name LocalSundialManager extends SundialManager

var island_name: String = "Primarina Island"
var first_marker_done: bool = false
var second_marker_done: bool = false

func get_island_name() -> String:
    if second_marker_done:
        return island_name
    return "Unknown Island Name"