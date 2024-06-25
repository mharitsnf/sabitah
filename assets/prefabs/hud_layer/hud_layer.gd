class_name HUDLayer extends CanvasLayer

@export_group("References")
@export var input_prompt_container: HBoxContainer

## Adds an input prompt into the HUD layer.
func add_input_prompt(new_ip: InputPrompt) -> void:
    if !new_ip.is_inside_tree():
        input_prompt_container.add_child.call_deferred(new_ip)

## Removes an input prompt into the HUD layer.
func remove_input_prompt(ip: InputPrompt) -> void:
    if ip.is_inside_tree():
        input_prompt_container.remove_child.call_deferred(ip)