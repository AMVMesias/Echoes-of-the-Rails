class_name CabinInteriorPolish
extends Node3D

@export var build_visual_panel: bool = true

var metal_material: StandardMaterial3D
var dark_material: StandardMaterial3D
var brass_material: StandardMaterial3D
var glass_material: StandardMaterial3D
var label_material: StandardMaterial3D
var red_material: StandardMaterial3D
var needle_material: StandardMaterial3D
var lamp_glow_material: StandardMaterial3D


func _ready() -> void:
	_create_materials()
	_add_interior_light()
	_add_oil_lamps()
	if build_visual_panel:
		_build_reference_panel()


func _create_materials() -> void:
	metal_material = _mat(Color(0.32, 0.29, 0.24), 0.78, 0.25)
	dark_material = _mat(Color(0.055, 0.050, 0.048), 0.9, 0.0)
	brass_material = _mat(Color(0.74, 0.51, 0.25), 0.42, 0.35)
	glass_material = _mat(Color(0.82, 0.78, 0.62, 0.55), 0.2, 0.0)
	glass_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	label_material = _mat(Color(0.025, 0.022, 0.020), 0.88, 0.0)
	red_material = _mat(Color(0.58, 0.06, 0.035), 0.65, 0.0)
	needle_material = _mat(Color(0.10, 0.04, 0.025), 0.7, 0.0)
	lamp_glow_material = _mat(Color(1.0, 0.72, 0.30), 0.25, 0.0)
	lamp_glow_material.emission_enabled = true
	lamp_glow_material.emission = Color(1.0, 0.56, 0.18)
	lamp_glow_material.emission_energy_multiplier = 1.8


func _mat(color: Color, roughness: float, metallic: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	material.metallic = metallic
	return material


func _add_interior_light() -> void:
	var light := OmniLight3D.new()
	light.name = "WarmCabinLight"
	light.position = Vector3(0.0, 2.05, 0.15)
	light.light_color = Color(1.0, 0.82, 0.58)
	light.light_energy = 3.8
	light.omni_range = 5.5
	light.shadow_enabled = false
	add_child(light)


func _add_oil_lamps() -> void:
	_create_oil_lamp(Vector3(-1.52, 1.12, -1.18))
	_create_oil_lamp(Vector3(1.52, 1.12, -1.18))


func _build_reference_panel() -> void:
	var panel := Node3D.new()
	panel.name = "HeroInstrumentPanel"
	panel.position = Vector3(0.0, 0.88, -0.84)
	panel.rotation_degrees.x = -18.0
	add_child(panel)

	_create_box_child(panel, "MainPlate", Vector3(0, 0, 0), Vector3(3.65, 0.12, 0.88), metal_material)
	_create_box_child(panel, "LowerDesk", Vector3(0, -0.40, 0.32), Vector3(3.65, 0.16, 0.92), metal_material)

	var gauge_positions: Array[Vector3] = [
		Vector3(-1.28, 0.10, -0.08),
		Vector3(-0.55, 0.10, -0.08),
		Vector3(0.18, 0.10, -0.08),
		Vector3(1.08, 0.10, -0.08)
	]
	var gauge_labels: Array[String] = ["VAPOR", "PRESION", "CARBON", "RELOJ"]
	for i in range(gauge_positions.size()):
		_create_gauge(panel, gauge_positions[i], gauge_labels[i], i)

	_create_label(panel, Vector3(0.68, 0.22, -0.51), "COMPRAR CARBON", 0.006)
	_create_label(panel, Vector3(0.68, 0.02, -0.51), "COMPRAR", 0.006)
	_create_label(panel, Vector3(0.68, -0.18, -0.51), "REINICIAR", 0.006)
	_create_box_child(panel, "CoalButtonPlate", Vector3(0.68, 0.02, -0.50), Vector3(0.86, 0.06, 0.22), dark_material)

	_create_visual_lever(panel, Vector3(-1.15, -0.53, 0.14), "REGULADOR DE VAPOR", Color(0.78, 0.18, 0.09))
	_create_visual_lever(panel, Vector3(0.85, -0.53, 0.14), "FRENO NEUMATICO", Color(0.70, 0.10, 0.08))
	_create_rivets(panel)


func _create_gauge(parent: Node3D, pos: Vector3, label_text: String, index: int) -> void:
	var ring_mesh := CylinderMesh.new()
	ring_mesh.top_radius = 0.245
	ring_mesh.bottom_radius = 0.245
	ring_mesh.height = 0.055
	ring_mesh.radial_segments = 32
	ring_mesh.surface_set_material(0, brass_material)
	var ring := MeshInstance3D.new()
	ring.name = "%sRing" % label_text
	ring.mesh = ring_mesh
	ring.position = pos
	ring.rotation_degrees.x = 90.0
	parent.add_child(ring)

	var face_mesh := CylinderMesh.new()
	face_mesh.top_radius = 0.205
	face_mesh.bottom_radius = 0.205
	face_mesh.height = 0.060
	face_mesh.radial_segments = 32
	face_mesh.surface_set_material(0, glass_material)
	var face := MeshInstance3D.new()
	face.name = "%sFace" % label_text
	face.mesh = face_mesh
	face.position = pos + Vector3(0.0, 0.002, -0.016)
	face.rotation_degrees.x = 90.0
	parent.add_child(face)

	var gauge_angles: Array[float] = [-32.0, -10.0, 42.0, 0.0]
	var needle_angle: float = gauge_angles[index]
	var needle := _create_box_child(parent, "%sNeedle" % label_text, pos + Vector3(0.0, 0.003, -0.052), Vector3(0.035, 0.30, 0.018), needle_material)
	needle.rotation_degrees.z = needle_angle

	_create_label(parent, pos + Vector3(0.0, -0.31, -0.06), label_text, 0.0048)


func _create_visual_lever(parent: Node3D, pos: Vector3, label_text: String, handle_color: Color) -> void:
	_create_box_child(parent, "%sSlot" % label_text, pos + Vector3(0.0, 0.0, -0.04), Vector3(0.66, 0.06, 0.18), dark_material)

	var stick_material := _mat(Color(0.42, 0.34, 0.25), 0.7, 0.15)
	var stick_mesh := CylinderMesh.new()
	stick_mesh.top_radius = 0.035
	stick_mesh.bottom_radius = 0.035
	stick_mesh.height = 0.62
	stick_mesh.radial_segments = 10
	stick_mesh.surface_set_material(0, stick_material)
	var stick := MeshInstance3D.new()
	stick.name = "%sStick" % label_text
	stick.mesh = stick_mesh
	stick.position = pos + Vector3(0.22, 0.02, 0.05)
	stick.rotation_degrees = Vector3(72.0, 0.0, 90.0)
	parent.add_child(stick)

	var handle_material := _mat(handle_color, 0.62, 0.0)
	var handle_mesh := SphereMesh.new()
	handle_mesh.radius = 0.105
	handle_mesh.height = 0.18
	handle_mesh.surface_set_material(0, handle_material)
	var handle := MeshInstance3D.new()
	handle.name = "%sHandle" % label_text
	handle.mesh = handle_mesh
	handle.position = pos + Vector3(0.50, 0.05, 0.06)
	parent.add_child(handle)

	_create_label(parent, pos + Vector3(0.0, -0.23, -0.04), label_text, 0.0048)


func _create_rivets(parent: Node3D) -> void:
	for x_index in range(17):
		var x: float = -1.72 + float(x_index) * 0.215
		_create_rivet(parent, Vector3(x, 0.44, -0.50))
		_create_rivet(parent, Vector3(x, -0.42, 0.66))
	for y_index in range(5):
		var y: float = -0.33 + float(y_index) * 0.18
		_create_rivet(parent, Vector3(-1.78, y, -0.50))
		_create_rivet(parent, Vector3(1.78, y, -0.50))


func _create_rivet(parent: Node3D, pos: Vector3) -> void:
	var mesh := SphereMesh.new()
	mesh.radius = 0.025
	mesh.height = 0.04
	mesh.radial_segments = 8
	mesh.surface_set_material(0, brass_material)
	var rivet := MeshInstance3D.new()
	rivet.mesh = mesh
	rivet.position = pos
	parent.add_child(rivet)


func _create_oil_lamp(pos: Vector3) -> void:
	var lamp := Node3D.new()
	lamp.name = "CabinOilLamp"
	lamp.position = pos
	add_child(lamp)

	_create_cylinder_child(lamp, Vector3(0, 0.11, 0), 0.11, 0.22, brass_material)
	_create_cylinder_child(lamp, Vector3(0, 0.32, 0), 0.075, 0.25, glass_material)

	var flame_mesh := SphereMesh.new()
	flame_mesh.radius = 0.065
	flame_mesh.height = 0.12
	flame_mesh.surface_set_material(0, lamp_glow_material)
	var flame := MeshInstance3D.new()
	flame.mesh = flame_mesh
	flame.position = Vector3(0, 0.34, 0)
	lamp.add_child(flame)

	var light := OmniLight3D.new()
	light.position = Vector3(0, 0.34, 0)
	light.light_color = Color(1.0, 0.66, 0.32)
	light.light_energy = 1.6
	light.omni_range = 2.6
	light.shadow_enabled = false
	lamp.add_child(light)


func _create_label(parent: Node3D, pos: Vector3, text: String, pixel_size: float) -> void:
	_create_box_child(parent, "%sPlate" % text, pos + Vector3(0.0, 0.0, 0.012), Vector3(max(0.34, float(text.length()) * 0.058), 0.045, 0.105), label_material)
	var label := Label3D.new()
	label.name = "%sLabel" % text
	label.text = text
	label.font_size = 24
	label.pixel_size = pixel_size
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.modulate = Color(0.92, 0.82, 0.64)
	label.position = pos + Vector3(0.0, 0.0, -0.045)
	label.rotation_degrees.x = -90.0
	parent.add_child(label)


func _create_box_child(parent: Node3D, node_name: String, pos: Vector3, size: Vector3, material: Material) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh.surface_set_material(0, material)
	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = mesh
	instance.position = pos
	parent.add_child(instance)
	return instance


func _create_cylinder_child(parent: Node3D, pos: Vector3, radius: float, height: float, material: Material) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 18
	mesh.surface_set_material(0, material)
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.position = pos
	parent.add_child(instance)
	return instance
