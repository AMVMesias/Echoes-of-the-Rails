class_name RouteSceneryBuilder
extends Node3D

@export var track_path: NodePath = NodePath("../TrackPath")
@export var tree_count: int = 150
@export var rock_count: int = 48
@export var passenger_count_near_start: int = 8
@export var generate_ground: bool = true

var rng := RandomNumberGenerator.new()
var ground_material: StandardMaterial3D
var rail_material: StandardMaterial3D
var sleeper_material: StandardMaterial3D
var trunk_material: StandardMaterial3D
var leaf_material: StandardMaterial3D
var rock_material: StandardMaterial3D
var silhouette_material: StandardMaterial3D


func _ready() -> void:
	rng.seed = 21052026
	call_deferred("_build_scenery")


func _build_scenery() -> void:
	var track := get_node_or_null(track_path) as Path3D
	if track == null or track.curve == null:
		return

	_create_materials()
	if generate_ground:
		_create_ground(track)
	_create_rail_highlights(track)
	_create_forest(track)
	_create_rocks(track)
	_create_station_silhouettes(track)


func _create_materials() -> void:
	ground_material = _make_material(Color(0.18, 0.29, 0.22), 0.95)
	rail_material = _make_material(Color(0.45, 0.48, 0.49), 0.55, 0.65)
	sleeper_material = _make_material(Color(0.25, 0.14, 0.08), 0.92)
	trunk_material = _make_material(Color(0.24, 0.13, 0.07), 0.9)
	leaf_material = _make_material(Color(0.10, 0.22, 0.15), 1.0)
	rock_material = _make_material(Color(0.32, 0.35, 0.36), 0.96)
	silhouette_material = _make_material(Color(0.055, 0.060, 0.062), 1.0)


func _make_material(color: Color, roughness: float, metallic: float = 0.0) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	material.metallic = metallic
	return material


func _create_ground(track: Path3D) -> void:
	var length: float = track.curve.get_baked_length()
	var ground_mesh := PlaneMesh.new()
	ground_mesh.size = Vector2(190.0, length + 180.0)
	ground_mesh.surface_set_material(0, ground_material)

	var ground := MeshInstance3D.new()
	ground.name = "FoggyGround"
	ground.mesh = ground_mesh
	add_child(ground)
	ground.global_position = track.to_global(Vector3(0.0, -0.12, -length * 0.48))


func _create_rail_highlights(track: Path3D) -> void:
	var length: float = track.curve.get_baked_length()
	var step: float = 3.0
	var distance: float = 0.0
	while distance < length:
		var point: Vector3 = track.curve.sample_baked(distance)
		var next_point: Vector3 = track.curve.sample_baked(min(distance + 2.0, length))
		var direction: Vector3 = (next_point - point).normalized()
		if direction.length() < 0.01:
			direction = Vector3.FORWARD
		var side: Vector3 = direction.cross(Vector3.UP).normalized()
		if side.length() < 0.01:
			side = Vector3.RIGHT

		_create_box("Sleeper", track.to_global(point + Vector3.UP * 0.04), Vector3(2.9, 0.08, 0.28), sleeper_material, direction)
		for offset in [-0.82, 0.82]:
			_create_box("Rail", track.to_global(point + side * offset + Vector3.UP * 0.16), Vector3(0.09, 0.10, step * 0.94), rail_material, direction)
		distance += step


func _create_forest(track: Path3D) -> void:
	var length: float = track.curve.get_baked_length()
	for i in range(tree_count):
		var distance: float = rng.randf_range(12.0, max(length - 20.0, 20.0))
		var point: Vector3 = track.curve.sample_baked(distance)
		var next_point: Vector3 = track.curve.sample_baked(min(distance + 2.0, length))
		var direction: Vector3 = (next_point - point).normalized()
		var side: Vector3 = direction.cross(Vector3.UP).normalized()
		if side.length() < 0.01:
			side = Vector3.RIGHT

		var side_sign: float = -1.0 if rng.randf() < 0.5 else 1.0
		var offset: float = rng.randf_range(8.0, 58.0) * side_sign
		var tree_position: Vector3 = track.to_global(point + side * offset + Vector3.UP * rng.randf_range(-0.3, 0.2))
		_create_tree(tree_position, rng.randf_range(0.75, 1.8))


func _create_rocks(track: Path3D) -> void:
	var length: float = track.curve.get_baked_length()
	for i in range(rock_count):
		var distance: float = rng.randf_range(20.0, max(length - 25.0, 25.0))
		var point: Vector3 = track.curve.sample_baked(distance)
		var next_point: Vector3 = track.curve.sample_baked(min(distance + 2.0, length))
		var direction: Vector3 = (next_point - point).normalized()
		var side: Vector3 = direction.cross(Vector3.UP).normalized()
		if side.length() < 0.01:
			side = Vector3.RIGHT
		var offset: float = rng.randf_range(7.0, 38.0) * (-1.0 if rng.randf() < 0.5 else 1.0)
		var rock_position: Vector3 = track.to_global(point + side * offset + Vector3.UP * 0.55)
		_create_rock(rock_position, rng.randf_range(0.8, 2.4))


func _create_station_silhouettes(track: Path3D) -> void:
	for i in range(passenger_count_near_start):
		var distance: float = rng.randf_range(75.0, 150.0)
		var point: Vector3 = track.curve.sample_baked(distance)
		var next_point: Vector3 = track.curve.sample_baked(distance + 2.0)
		var direction: Vector3 = (next_point - point).normalized()
		var side: Vector3 = direction.cross(Vector3.UP).normalized()
		if side.length() < 0.01:
			side = Vector3.RIGHT
		var offset: float = -rng.randf_range(5.2, 8.8)
		var position: Vector3 = track.to_global(point + side * offset)
		_create_passenger_silhouette(position, rng.randf_range(0.85, 1.15))

	_create_lamp(track.to_global(track.curve.sample_baked(95.0) + Vector3(-4.6, 0.0, 0.0)))


func _create_tree(position: Vector3, scale_factor: float) -> void:
	var tree := Node3D.new()
	tree.name = "Pine"
	add_child(tree)
	tree.global_position = position

	var trunk_mesh := CylinderMesh.new()
	trunk_mesh.top_radius = 0.11 * scale_factor
	trunk_mesh.bottom_radius = 0.16 * scale_factor
	trunk_mesh.height = 2.1 * scale_factor
	trunk_mesh.radial_segments = 6
	trunk_mesh.surface_set_material(0, trunk_material)
	var trunk := MeshInstance3D.new()
	trunk.mesh = trunk_mesh
	trunk.position.y = trunk_mesh.height * 0.5
	tree.add_child(trunk)

	for tier in range(3):
		var crown_mesh := CylinderMesh.new()
		crown_mesh.top_radius = 0.0
		crown_mesh.bottom_radius = (1.25 - float(tier) * 0.24) * scale_factor
		crown_mesh.height = (2.0 - float(tier) * 0.22) * scale_factor
		crown_mesh.radial_segments = 6
		crown_mesh.surface_set_material(0, leaf_material)
		var crown := MeshInstance3D.new()
		crown.mesh = crown_mesh
		crown.position.y = (2.25 + float(tier) * 0.72) * scale_factor
		crown.rotation_degrees.y = rng.randf_range(0.0, 60.0)
		tree.add_child(crown)


func _create_rock(position: Vector3, scale_factor: float) -> void:
	var mesh := SphereMesh.new()
	mesh.radius = 0.65 * scale_factor
	mesh.height = 0.92 * scale_factor
	mesh.radial_segments = 7
	mesh.rings = 4
	mesh.surface_set_material(0, rock_material)
	var rock := MeshInstance3D.new()
	rock.name = "LowPolyRock"
	rock.mesh = mesh
	rock.scale = Vector3(1.5, 0.58, 1.0)
	rock.rotation_degrees = Vector3(rng.randf_range(-8.0, 8.0), rng.randf_range(0.0, 180.0), rng.randf_range(-8.0, 8.0))
	add_child(rock)
	rock.global_position = position


func _create_passenger_silhouette(position: Vector3, scale_factor: float) -> void:
	var figure := Node3D.new()
	figure.name = "PassengerSilhouette"
	add_child(figure)
	figure.global_position = position

	var body_mesh := CapsuleMesh.new()
	body_mesh.radius = 0.20 * scale_factor
	body_mesh.height = 1.25 * scale_factor
	body_mesh.radial_segments = 8
	body_mesh.surface_set_material(0, silhouette_material)
	var body := MeshInstance3D.new()
	body.mesh = body_mesh
	body.position.y = 0.72 * scale_factor
	figure.add_child(body)

	var hood_mesh := SphereMesh.new()
	hood_mesh.radius = 0.22 * scale_factor
	hood_mesh.height = 0.34 * scale_factor
	hood_mesh.radial_segments = 8
	hood_mesh.surface_set_material(0, silhouette_material)
	var hood := MeshInstance3D.new()
	hood.mesh = hood_mesh
	hood.position.y = 1.48 * scale_factor
	figure.add_child(hood)


func _create_lamp(position: Vector3) -> void:
	var lamp := Node3D.new()
	lamp.name = "PlatformLamp"
	add_child(lamp)
	lamp.global_position = position + Vector3.UP * 0.2

	_create_cylinder_child(lamp, Vector3(0.0, 0.7, 0.0), 0.05, 1.4, silhouette_material)

	var glow_material := StandardMaterial3D.new()
	glow_material.albedo_color = Color(1.0, 0.76, 0.34)
	glow_material.emission_enabled = true
	glow_material.emission = Color(1.0, 0.62, 0.22)
	glow_material.emission_energy_multiplier = 1.4
	var globe_mesh := SphereMesh.new()
	globe_mesh.radius = 0.18
	globe_mesh.height = 0.32
	globe_mesh.surface_set_material(0, glow_material)
	var globe := MeshInstance3D.new()
	globe.mesh = globe_mesh
	globe.position.y = 1.55
	lamp.add_child(globe)

	var light := OmniLight3D.new()
	light.position.y = 1.55
	light.light_color = Color(1.0, 0.74, 0.40)
	light.light_energy = 1.2
	light.omni_range = 8.0
	lamp.add_child(light)


func _create_box(node_name: String, global_pos: Vector3, size: Vector3, material: Material, direction: Vector3) -> void:
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh.surface_set_material(0, material)
	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = mesh
	add_child(instance)
	instance.global_position = global_pos
	instance.look_at(global_pos + direction, Vector3.UP)


func _create_cylinder_child(parent: Node3D, local_pos: Vector3, radius: float, height: float, material: Material) -> void:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 8
	mesh.surface_set_material(0, material)
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.position = local_pos
	parent.add_child(instance)
