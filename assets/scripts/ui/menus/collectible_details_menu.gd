class_name CollectibleDetailsMenu extends BaseMenu

@export var title_label: Label
@export var description_label: Label

func _ready() -> void:
	super()
	assert(title_label)
	assert(description_label)

func set_data(new_data: Dictionary) -> void:
	if !new_data.is_empty():
		assert(new_data.has('collectible_id'))
		assert(new_data['collectible_id'] is String)
		
		data = new_data
		data['collectible'] = (CollectibleState.get_collectible_data_by_id(data["collectible_id"]) as CollectibleData).get_collectible()

		title_label.text = (data['collectible'] as Collectible).title
		description_label.text = (data['collectible'] as Collectible).description
