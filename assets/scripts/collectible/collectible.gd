class_name Collectible extends Resource

@export var id: String
@export var title: String
@export_multiline var description: String
@export var status: CollectibleState.CollectibleStatus
@export var type: CollectibleState.CollectibleType