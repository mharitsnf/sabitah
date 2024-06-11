class_name OceanData extends Node3D

@export_group("Follow target")
@export var target : BaseActor

@export_group("Wave data")
@export var wave_data_1 : Vector4
@export var wave_data_2 : Vector4
@export var wave_data_3 : Vector4
@export var wave_data_4 : Vector4
@export var wave_data_5 : Vector4
@export var speed : float = 1.

var target_world_pos: Vector3 = Vector3.ZERO
var target_basis: Basis = Basis.IDENTITY

var transitioning: bool = false

# Transform variables
var default_initial_position : Vector3 = Vector3(0., State.Game.PLANET_RADIUS, 0.)
var initial_position : Vector3 = default_initial_position
var initial_basis : Basis = Basis.IDENTITY
var offset : Vector3 = Vector3.ZERO

var time_elapsed : float = 0.

func _process(delta: float) -> void:
    time_elapsed += delta