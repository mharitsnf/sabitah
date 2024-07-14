class_name HUDLayer extends CanvasLayer

@export_group("References")
@export var input_prompt_container: HBoxContainer

var menu_layer: MenuLayer

func _ready() -> void:
	menu_layer = Group.first("menu_layer")
	assert(menu_layer)
	(menu_layer as MenuLayer).menu_entered.connect(_on_menu_entered)
	(menu_layer as MenuLayer).menu_exited.connect(_on_menu_exited)

	Common.dialogue_entered.connect(_hide_input_prompt)
	Common.dialogue_exited.connect(_show_input_prompt)

func _on_menu_entered(_data: MenuData) -> void:
	_hide_input_prompt()

func _on_menu_exited(_data: MenuData) -> void:
	if menu_layer.history_stack.is_empty():
		_show_input_prompt()

func _hide_input_prompt() -> void:
	input_prompt_container.visible = false

func _show_input_prompt() -> void:
	input_prompt_container.visible = true

## Adds an input prompt into the HUD layer.
func add_input_prompt(new_ip: InputPrompt) -> void:
	if !new_ip.is_inside_tree():
		input_prompt_container.add_child.call_deferred(new_ip)

## Removes an input prompt into the HUD layer.
func remove_input_prompt(ip: InputPrompt) -> void:
	if ip.is_inside_tree():
		input_prompt_container.remove_child.call_deferred(ip)