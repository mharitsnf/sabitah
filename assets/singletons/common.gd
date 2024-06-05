extends Node

func _ready() -> void:
    # Input
    InputState.current_device = InputHelper.guess_device_name()
    InputHelper.device_changed.connect(InputState._on_input_device_changed)

func wait(sec: float) -> void:
    await get_tree().create_timer(sec).timeout

class Geometry extends RefCounted:
    static func adjust_basis_to_normal(old_basis: Basis, new_normal: Vector3) -> Basis:
        new_normal = new_normal.normalized()
        var quat : Quaternion = Quaternion(old_basis.y, new_normal).normalized()
        var new_right : Vector3 = quat * old_basis.x
        var new_forward : Vector3 = quat * old_basis.z
        return Basis(new_right, new_normal, new_forward).orthonormalized()

class InputState extends RefCounted:
    static var current_device: String

    static func is_keyboard_active() -> bool:
        return current_device == InputHelper.DEVICE_KEYBOARD
    
    static func _on_input_device_changed(device: String, _device_index: int) -> void:
        current_device = device

class Promise extends RefCounted:
    signal completed
    func _init() -> void: completed.emit()

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