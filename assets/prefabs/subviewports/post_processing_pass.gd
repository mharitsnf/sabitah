class_name PostProcessingPass extends SubViewportContainer

@export var viewport: SubViewport
@export var game_texture: ColorRect

func _ready() -> void:
    assert(viewport)
    assert(game_texture)