class_name MentalImageMenu extends BaseMenu

@export var texture_rect: TextureRect

func set_data(new_data: Dictionary) -> void:
	if !new_data.is_empty():
		assert(new_data.has('mental_image_id'))

		data = new_data
		var mental_images: Array[MentalImageData] = MemoryState.get_mental_images({ "id": data['mental_image_id'] })
		assert((mental_images as Array).size() > 0)
		data['mental_image_data'] = mental_images[0]

		texture_rect.texture = (data['mental_image_data'] as MentalImageData).get_mental_image().image_tex