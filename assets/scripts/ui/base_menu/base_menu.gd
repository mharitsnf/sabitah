class_name BaseMenu extends Control

@onready var anim: AnimationPlayer = $AnimationPlayer

var data: Dictionary

var menu_layer: MenuLayer
var game_viewport: SubViewport

func _ready() -> void:
    assert(anim)
    menu_layer = Group.first("menu_layer")
    assert(menu_layer)
    game_viewport = Group.first("game_viewport")
    assert(game_viewport)

func _input(event: InputEvent) -> void:
    if menu_layer.switching: return
    if event.is_action_pressed("ui_cancel"):
        menu_layer.back()
        game_viewport.set_input_as_handled()

func set_data(new_data: Dictionary) -> void:
    data = new_data

func about_to_exit() -> void:
    anim.play("tree_exiting")
    await anim.animation_finished

func after_entering() -> void:
    if !is_node_ready(): await ready
    anim.play("tree_entered")
    await anim.animation_finished
