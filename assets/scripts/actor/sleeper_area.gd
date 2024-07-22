extends Area3D

var actor: BaseActor
var player_characters: Array

func _ready() -> void:
	actor = get_parent()
	assert(actor)
	assert(actor is BaseActor)

func _on_body_exited(body: Node3D) -> void:
	player_characters.erase(body)
	if player_characters.is_empty():
		actor.sleeping = true
		print(name, " ", body.name, " ", actor.sleeping)

func _on_body_entered(body: Node3D) -> void:
	player_characters.append(body)
	actor.sleeping = false
	print(name, " ", body.name, " ", actor.sleeping)
