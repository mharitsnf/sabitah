extends Node

class Geometry extends RefCounted:
    static func adjust_basis_to_normal(old_basis: Basis, new_normal: Vector3) -> Basis:
        new_normal = new_normal.normalized()
        var quat : Quaternion = Quaternion(old_basis.y, new_normal).normalized()
        var new_right : Vector3 = quat * old_basis.x
        var new_forward : Vector3 = quat * old_basis.z
        return Basis(new_right, new_normal, new_forward).orthonormalized()

## Factory class for [RemoteTransform3D]
class RemoteTransform3DBuilder extends RefCounted:
    var _rt: RemoteTransform3D
    
    # Constructor
    func _init() -> void:
        reset()
    
    ## Resets the current [RemoteTransform3D] instance.
    func reset() -> RemoteTransform3DBuilder:
        _rt = RemoteTransform3D.new()
        _rt.name = "FollowedBy"
        return self

    ## Renames the current [RemoteTransform3D].
    func rename(new_name: String) ->  RemoteTransform3DBuilder:
        _rt.name = "FollowedBy" + new_name
        return self
    
    ## Set the [update_rotation] value of the [RemoteTransform3D].
    func update_rotation(value: bool = true) -> RemoteTransform3DBuilder:
        _rt.update_rotation = value
        return self
    
    func set_path(path: NodePath) -> RemoteTransform3DBuilder:
        _rt.remote_path = path
        return self

    ## Returns the instantiated [RemoteTransform3D], and then resets the instance to a new one.
    func get_remote_transform() -> RemoteTransform3D:
        var result: RemoteTransform3D = _rt
        reset()
        return result
    
