extends Node

## Add a [node] to a group of name [group_name].
func add(group_name: String, node: Node) -> void:
    if !node.is_in_group(group_name):
        node.add_to_group(group_name)

## Remove a [node] from a group of name [group_name].
func remove(group_name: String, node: Node) -> void:
    if node.is_in_group(group_name):
        node.remove_from_group(group_name)

## Returns the first node from a group of name [group_name].
func first(group_name: String) -> Node:
    return get_tree().get_first_node_in_group(group_name)

## Returns the index of a [node] inside a group of name [group_name].
func index_of(group_name: String, node: Node) -> int:
    return get_tree().get_nodes_in_group(group_name).find(node)

## Checks if group of name [group_name] has [node].
func has(group_name: String, node: Node) -> bool:
    return get_tree().get_nodes_in_group(group_name).has(node)