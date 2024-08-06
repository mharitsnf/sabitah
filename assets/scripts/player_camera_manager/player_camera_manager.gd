class_name PlayerCameraManager extends Node

@export_group("Cameras")
@export var third_person_camera: ThirdPersonCamera
@export var first_person_camera: FirstPersonCamera

var _current_camera: VirtualCamera

func _ready() -> void:
	assert(third_person_camera)

func has_camera(target: VirtualCamera) -> bool:
	if target == third_person_camera: return true
	if target == first_person_camera: return true
	return false

## Returns the entry camera; the first camera to be activated when switching to this actor.
func get_entry_camera() -> VirtualCamera:
	return third_person_camera

## Sets the currently active camera.
func set_current_camera(value: VirtualCamera) -> void:
	_current_camera = value

## Get the next camera to be activated.
func get_next_camera() -> VirtualCamera:
	if !first_person_camera:
		return third_person_camera
	
	if _current_camera == third_person_camera:
		return first_person_camera
	else:
		return third_person_camera