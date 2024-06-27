class_name BaseMenu extends Control

@onready var anim: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
    assert(anim)

func about_to_exit() -> void:
    anim.play("tree_exiting")
    await anim.animation_finished

func after_entering() -> void:
    if !is_node_ready(): await ready
    anim.play("tree_entered")
    await anim.animation_finished
