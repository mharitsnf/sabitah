class_name SundialManager extends Node3D

@export_group("Parameters")
@export var latmes_rotate_speed: float = 2.5
@export_group("References")
@export var sundial_center: Marker3D
@export_subgroup("Packed scenes")
@export var latitude_measure_pscn: PackedScene
@export var sundial_pscn: PackedScene

var latitude_measure: Node3D
var latitude_measure_mesh: MeshInstance3D
var sundial: Node3D

var latitude_measure_rt: RemoteTransform3D
var sundial_rt: RemoteTransform3D

const SUNDIAL_ROTATION_STEP: float = deg_to_rad(15)

func _ready() -> void:
	assert(sundial_center)
	assert(latitude_measure_pscn)
	assert(sundial_pscn)

	_initiate_sundial()

## Rotates the latitude measurement.
func rotate_latmes(amount: float) -> void:
	if amount != 0:
		latitude_measure_mesh.rotate_y(amount * latmes_rotate_speed * get_process_delta_time())

## Rotates the sundial.
func rotate_sundial(amount: float) -> void:
	if amount != 0:
		sundial.rotate_y(amount)

## Private. Initiate sundial using remote transform.
func _initiate_sundial() -> void:
	var level: Node3D = State.get_level(State.LevelType.MAIN)

	sundial = sundial_pscn.instantiate()
	level.add_child.call_deferred(sundial)
	latitude_measure = latitude_measure_pscn.instantiate()
	level.add_child.call_deferred(latitude_measure)
	
	await latitude_measure.ready

	latitude_measure_mesh = latitude_measure.get_node("LatitudeMeasure")
	assert(latitude_measure_mesh)

	var rtb_sundial: Common.RemoteTransform3DBuilder = Common.RemoteTransform3DBuilder.new()
	rtb_sundial.rename("Sundial")
	rtb_sundial.update_rotation(false)
	rtb_sundial.set_path(sundial.get_path())
	sundial_rt = rtb_sundial.get_remote_transform()
	sundial_center.add_child.call_deferred(sundial_rt)

	var rtb_latmes: Common.RemoteTransform3DBuilder = Common.RemoteTransform3DBuilder.new()
	rtb_latmes.rename("LatitudeMeasure")
	rtb_latmes.update_rotation(true)
	rtb_latmes.set_path(latitude_measure.get_path())
	latitude_measure_rt = rtb_latmes.get_remote_transform()
	sundial_center.add_child.call_deferred(latitude_measure_rt)
