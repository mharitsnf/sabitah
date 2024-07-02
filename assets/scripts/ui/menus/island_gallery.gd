class_name IslandGallery extends BaseMenu

@export_group("References")
@export var add_picture_button: GenericButton
@export var pictures_container: GridContainer
@export var island_name_label: Label
@export var left_arrow: TextureRect
@export var right_arrow: TextureRect

func _ready() -> void:
    super()
    assert(add_picture_button)
    assert(pictures_container)
    assert(island_name_label)
    assert(left_arrow)
    assert(right_arrow)

func set_left_arrow_visibility(arrow_visible: bool) -> void:
    left_arrow.modulate = Color(1.,1.,1.,1.) if arrow_visible else Color(1.,1.,1.,0.)

func set_right_arrow_visibility(arrow_visible: bool) -> void:
    right_arrow.modulate = Color(1.,1.,1.,1.) if arrow_visible else Color(1.,1.,1.,0.)

func set_data(new_data: Dictionary) -> void:
    data = new_data
    island_name_label.text = (data["sundial_manager"] as LocalSundialManager).get_island_name()

func about_to_exit() -> void:
    await super()
    add_picture_button.release_focus()

# Overridden
func after_entering() -> void:
    await super()
    add_picture_button.grab_focus()