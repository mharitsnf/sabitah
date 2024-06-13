class_name NavigationTarget extends Marker3D

var nav_factory: Common.NavigationTargetFactory

func _enter_tree() -> void:
    if !nav_factory:
        nav_factory = Common.NavigationTargetFactory.new(self)
    nav_factory.add_to_nav_world()

func _exit_tree() -> void:
    nav_factory.remove_from_nav_world()

## Return the navigation target inside the navigation world
func get_nav_target() -> Marker3D:
    return nav_factory.get_nav_target()