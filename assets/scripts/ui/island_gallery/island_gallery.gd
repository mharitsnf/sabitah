class_name IslandGallery extends BaseMenu

@export_group("References")
@export var island_name_label: Label
@export var left_arrow: TextureRect
@export var right_arrow: TextureRect

func set_left_arrow_visibility(arrow_visible: bool) -> void:
    left_arrow.modulate = Color(1.,1.,1.,1.) if arrow_visible else Color(1.,1.,1.,0.)

func set_right_arrow_visibility(arrow_visible: bool) -> void:
    right_arrow.modulate = Color(1.,1.,1.,1.) if arrow_visible else Color(1.,1.,1.,0.)

func set_data(new_data: Dictionary) -> void:
    super(new_data)
    island_name_label.text = (data["sundial_manager"] as LocalSundialManager).get_island_name()