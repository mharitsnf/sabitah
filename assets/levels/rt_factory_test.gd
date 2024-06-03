extends Node

func _ready() -> void:
    var rt_builder: Common.RemoteTransform3DBuilder = Common.RemoteTransform3DBuilder.new()
    rt_builder.rename("NodeA").update_rotation(true)
    var rt: RemoteTransform3D = rt_builder.get_remote_transform()
    print(rt, " update_rotation: ", rt.update_rotation)

    rt_builder.rename("NodeB")
    var rt1: RemoteTransform3D = rt_builder.get_remote_transform()
    print(rt, " update_rotation: ", rt.update_rotation)
    print(rt1, " update_rotation: ", rt1.update_rotation)
