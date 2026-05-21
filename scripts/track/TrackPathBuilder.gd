class_name TrackPathBuilder
extends Path3D

@export var generate_placeholder_rails: bool = true
@export var rail_segment_count: int = 96


func _ready() -> void:
	if curve == null or curve.point_count == 0:
		_build_curve()
	if generate_placeholder_rails and not has_node("PlaceholderRails"):
		_build_placeholder_rails()


func _build_curve() -> void:
	curve = Curve3D.new()
	curve.bake_interval = 2.0
	curve.add_point(Vector3(0.0, 0.0, 0.0), Vector3.ZERO, Vector3(0.0, 0.0, -45.0))
	curve.add_point(Vector3(18.0, 1.5, -160.0), Vector3(-18.0, 0.0, 55.0), Vector3(25.0, 0.0, -60.0))
	curve.add_point(Vector3(-26.0, 4.0, -345.0), Vector3(28.0, 0.0, 60.0), Vector3(-28.0, 0.0, -60.0))
	curve.add_point(Vector3(36.0, 7.5, -535.0), Vector3(-35.0, 0.0, 55.0), Vector3(35.0, 0.0, -55.0))
	curve.add_point(Vector3(-18.0, 11.0, -725.0), Vector3(30.0, 0.0, 60.0), Vector3(-30.0, 0.0, -60.0))
	curve.add_point(Vector3(8.0, 14.0, -960.0), Vector3(-10.0, 0.0, 70.0), Vector3(28.0, 0.0, -85.0))
	curve.add_point(Vector3(55.0, 17.0, -1240.0), Vector3(-38.0, 0.0, 85.0), Vector3(32.0, 0.0, -80.0))
	curve.add_point(Vector3(-35.0, 20.0, -1510.0), Vector3(44.0, 0.0, 80.0), Vector3(-38.0, 0.0, -92.0))
	curve.add_point(Vector3(12.0, 23.0, -1810.0), Vector3(-24.0, 0.0, 90.0), Vector3.ZERO)


func _build_placeholder_rails() -> void:
	var rails_root := Node3D.new()
	rails_root.name = "PlaceholderRails"
	add_child(rails_root)

	var length := curve.get_baked_length()
	var step := length / float(max(rail_segment_count, 1))
	for i in range(rail_segment_count):
		var distance := step * float(i)
		var point := curve.sample_baked(distance)
		var next := curve.sample_baked(min(distance + 2.0, length))
		var direction := (next - point).normalized()
		if direction.length() < 0.01:
			direction = Vector3.FORWARD
		var side := direction.cross(Vector3.UP).normalized()
		if side.length() < 0.01:
			side = Vector3.RIGHT

		var sleeper := MeshInstance3D.new()
		sleeper.name = "Sleeper%02d" % i
		var mesh := BoxMesh.new()
		mesh.size = Vector3(4.0, 0.18, 0.65)
		sleeper.mesh = mesh
		sleeper.position = point
		rails_root.add_child(sleeper)
		sleeper.look_at(point + direction, Vector3.UP)

		for offset in [-1.15, 1.15]:
			var rail := MeshInstance3D.new()
			rail.name = "Rail%02d_%s" % [i, "L" if offset < 0.0 else "R"]
			var rail_mesh := BoxMesh.new()
			rail_mesh.size = Vector3(0.16, 0.16, step * 0.95)
			rail.mesh = rail_mesh
			rail.position = point + side * offset + Vector3.UP * 0.18
			rails_root.add_child(rail)
			rail.look_at(rail.position + direction, Vector3.UP)
