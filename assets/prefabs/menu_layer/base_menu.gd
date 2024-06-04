class_name BaseMenu extends Control

@onready var anim: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
    assert(anim)

func about_to_exit() -> Common.Promise:
    anim.play("tree_exiting")
    await anim.animation_finished
    return Common.Promise.new()

func after_entering() -> Common.Promise:
    if !is_node_ready(): await ready
    anim.play("tree_entered")
    await anim.animation_finished
    return Common.Promise.new()
