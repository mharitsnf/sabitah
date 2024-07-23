@tool
class_name LineMesh extends CSGPolygon3D

@export var line_radius: float = 1.:
	set(value):
		line_radius = value
		_generate_circle()
@export var line_resolution: int = 64:
	set(value):
		line_resolution = value
		_generate_circle()
@export var points: Array[Vector3] = []:
	set(value):
		points = value
		_set_points()

@export_group("References")
@export var path_3d: Path3D

func _set_points() -> void:
	var curve: Curve3D = Curve3D.new()
	for p: Vector3 in points:
		curve.add_point(p)
	path_3d.curve = curve

func _generate_circle() -> void:
	var circle: PackedVector2Array = []
	for deg: int in line_resolution:
		var x: float = line_radius * sin(PI * 2. * float(deg) / float(line_resolution))
		var y: float = line_radius * cos(PI * 2. * float(deg) / float(line_resolution))
		circle.append(Vector2(x, y))
	polygon = circle
