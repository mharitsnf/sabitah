extends Label

func _ready() -> void:
	DialogueManager.got_dialogue.connect(_on_got_dialogue)

func _on_got_dialogue(line: DialogueLine) -> void:
	print(line)