extends Node

var free_mode: bool = false

var global_progress: Dictionary = {
	"boat_code_received": _boat_code_received,
	"first_island_registered": false
}

var progress: Dictionary = {
	"tutorial_island": {
		"teacher": {
		},
		"townfolk1": {
		}
	}
}

func _boat_code_received() -> bool:
	var memories: Array[MemoryData] = MemoryState.get_memories({ "id": "mm_boat_code_1" })
	if memories.is_empty(): return false
	var md: MemoryData = memories[0]
	return md.get_memory().locked_status == Memory.LockedStatus.UNLOCKED

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
