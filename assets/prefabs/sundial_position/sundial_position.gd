class_name SundialPosition extends Marker3D

@export var offset: Vector3 = Vector3.ZERO
@export_group("References")
@export_subgroup("Packed scenes")
@export var latitude_measure_pscn: PackedScene
@export var sundial_pscn: PackedScene

var latitude_measure: Node3D
var sundial: Node3D

var latitude_measure_rt: RemoteTransform3D
var sundial_rt: RemoteTransform3D

func _ready() -> void:
    position += offset

    var level: Node3D = State.get_level(State.LevelType.MAIN)

    sundial = sundial_pscn.instantiate()
    level.add_child.call_deferred(sundial)
    latitude_measure = latitude_measure_pscn.instantiate()
    level.add_child.call_deferred(latitude_measure)
    
    await latitude_measure.ready

    var rtb_sundial: Common.RemoteTransform3DBuilder = Common.RemoteTransform3DBuilder.new()
    rtb_sundial.rename("Sundial")
    rtb_sundial.update_rotation(false)
    rtb_sundial.set_path(sundial.get_path())
    sundial_rt = rtb_sundial.get_remote_transform()
    add_child.call_deferred(sundial_rt)

    var rtb_latmes: Common.RemoteTransform3DBuilder = Common.RemoteTransform3DBuilder.new()
    rtb_latmes.rename("LatitudeMeasure")
    rtb_latmes.update_rotation(true)
    rtb_latmes.set_path(latitude_measure.get_path())
    latitude_measure_rt = rtb_latmes.get_remote_transform()
    add_child.call_deferred(latitude_measure_rt)