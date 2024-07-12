extends Node

@export var generate: bool

func _on_generate_true(value: bool) -> void:
	generate = value
	if !generate: return

	var mesh_instances: Array[Node] = get_parent().get_children()
	mesh_instances.erase(self)

	for mesh_instance: Node in mesh_instances:
		if !(mesh_instance is MeshInstance3D): continue
		var mesh: Mesh = (mesh_instance as MeshInstance3D).mesh
		mesh.create_trimesh_shape()