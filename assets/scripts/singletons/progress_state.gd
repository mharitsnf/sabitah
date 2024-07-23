extends Node

var free_mode: bool = false

var global_progress: Dictionary = {
	"first_introduction": false,
	"globe_menu_unlocked": false,
	"help_menu_unlocked": false,
	"boat_key_received": func () -> bool: return CollectibleState.get_collectible_status("boat_key") == CollectibleState.CollectibleStatus.OBTAINED,
	"tutorial_island_registered": false,
	"tutorial_island_set_as_node_island": false,
	"boat_key_fixed": false
}

var progress: Dictionary = {
	"tutorial_island": {
		"teacher": {
			"intro": false,
			"sundial_intro": false,
			"node_island_intro": false,
			"end_test_intro": false,
		},
		"townfolk1": {
			"intro": false,
		}
	}
}

## Get the global progress value of the specified [keys]. If [free_mode] is true, the function
## will return true regardless of the specified state.
func get_global_progress(keys: Array) -> bool:
	if free_mode: return true
	return _get_dict_value(global_progress, keys)

func get_progress(keys: Array[String]) -> bool:
	if free_mode: return true
	return _get_dict_value(progress, keys)

func _get_dict_value(dict: Dictionary, keys: Array) -> bool:
	var key: String = keys.pop_front()
	if !dict.has(key):
		push_error("Dictionary has no key " + key)
		return false

	var result: Variant = dict[key]
	if result is Callable:
		result = (result as Callable).call()
	if result is bool:
		return result
	
	return _get_dict_value(result, keys)
