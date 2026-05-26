@tool
class_name CabinInteriorPolish
extends Node3D

@export var build_visual_panel: bool = true
@export var panel_position: Vector3 = Vector3(0.0, 1.02, -1.64):
	set(value):
		panel_position = value
		if Engine.is_editor_hint() and is_inside_tree():
			_apply_panel_export_transform()
@export_range(-30.0, 10.0, 0.5) var panel_tilt_degrees: float = -14.0:
	set(value):
		panel_tilt_degrees = value
		if Engine.is_editor_hint() and is_inside_tree():
			_apply_panel_export_transform()
@export var panel_rotation_degrees: Vector3 = Vector3(0.0, 0.0, 0.0):
	set(value):
		panel_rotation_degrees = value
		if Engine.is_editor_hint() and is_inside_tree():
			_apply_panel_export_transform()

const GENERATED_CHILD_NAMES := {
	"WarmCabinLight": true,
	"PanelAccentLight": true,
	"CabinOilLampLeft": true,
	"CabinOilLampRight": true,
	"HeroInstrumentPanel": true,
}

var brass_material: Material
var label_bg_material: Material
var needle_material: Material
var lamp_glow_material: StandardMaterial3D
var glass_material: StandardMaterial3D
var dark_slot_material: Material
var green_zone_material: Material
var red_zone_material: Material
var cream_face_material: Material
var metal_material: Material
var grime_material: Material


func _ready() -> void:
	_ensure_generated_scene_parts()


func _ensure_generated_scene_parts() -> void:
	_create_procedural_materials()

	if not has_node("WarmCabinLight"):
		_add_ceiling_light()
	if not has_node("PanelAccentLight"):
		_add_panel_light()
	if not has_node("CabinOilLampLeft"):
		_create_oil_lamp("CabinOilLampLeft", Vector3(-2.05, 1.55, -2.58))
	if not has_node("CabinOilLampRight"):
		_create_oil_lamp("CabinOilLampRight", Vector3(2.05, 1.55, -2.58))
	if build_visual_panel and not has_node("HeroInstrumentPanel"):
		_build_instrument_panel()
	if Engine.is_editor_hint():
		_assign_owner_to_generated_parts()
		call_deferred("_assign_owner_to_generated_parts")


func _apply_panel_export_transform() -> void:
	var panel := get_node_or_null("HeroInstrumentPanel") as Node3D
	if panel == null:
		return
	panel.position = panel_position
	panel.rotation_degrees = Vector3(panel_tilt_degrees, panel_rotation_degrees.y, panel_rotation_degrees.z)


func _assign_owner_to_generated_parts() -> void:
	var scene_root := get_tree().edited_scene_root
	if scene_root == null:
		scene_root = owner
	if scene_root == null:
		return
	for child in get_children():
		if GENERATED_CHILD_NAMES.has(child.name):
			_set_owner_recursive(child, scene_root)


func _set_owner_recursive(node: Node, scene_root: Node) -> void:
	node.owner = scene_root
	for child in node.get_children():
		_set_owner_recursive(child, scene_root)


func _create_procedural_materials() -> void:
	brass_material = _material_or_fallback("res://assets/materials/train_aged_brass_weathered.tres", Color(0.42, 0.31, 0.16), 0.62, 0.25)
	metal_material = _material_or_fallback("res://assets/materials/train_oxidized_lead_metal.tres", Color(0.24, 0.255, 0.25), 0.82, 0.58)
	cream_face_material = _mat(Color(0.85, 0.80, 0.68), 0.85, 0.0)
	label_bg_material = _material_or_fallback("res://assets/materials/train_cool_black_metal.tres", Color(0.025, 0.027, 0.028), 0.86, 0.5)
	needle_material = _material_or_fallback("res://assets/materials/train_dark_iron_weathered.tres", Color(0.10, 0.04, 0.025), 0.7, 0.0)
	dark_slot_material = _material_or_fallback("res://assets/materials/train_black_iron_weathered.tres", Color(0.04, 0.035, 0.03), 0.92, 0.0)
	green_zone_material = _mat(Color(0.10, 0.35, 0.08), 0.75, 0.0)
	red_zone_material = _mat(Color(0.50, 0.06, 0.04), 0.75, 0.0)
	glass_material = _mat(Color(0.78, 0.74, 0.58, 0.40), 0.20, 0.0)
	glass_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	lamp_glow_material = _mat(Color(1.0, 0.72, 0.30), 0.25, 0.0)
	lamp_glow_material.emission_enabled = true
	lamp_glow_material.emission = Color(1.0, 0.56, 0.18)
	lamp_glow_material.emission_energy_multiplier = 1.8
	grime_material = _mat(Color(0.12, 0.10, 0.08), 0.95, 0.0)


func _material_or_fallback(path: String, color: Color, roughness: float, metallic: float) -> Material:
	if ResourceLoader.exists(path):
		var loaded: Resource = load(path)
		if loaded is Material:
			return loaded as Material
	return _mat(color, roughness, metallic)


func _mat(color: Color, roughness: float, metallic: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	material.metallic = metallic
	return material


func _add_ceiling_light() -> void:
	var ceiling := OmniLight3D.new()
	ceiling.name = "WarmCabinLight"
	ceiling.position = Vector3(0.0, 2.85, 0.0)
	ceiling.light_color = Color(1.0, 0.88, 0.72)
	ceiling.light_energy = 2.5
	ceiling.omni_range = 7.0
	ceiling.shadow_enabled = false
	add_child(ceiling)


func _add_panel_light() -> void:
	var panel_light := OmniLight3D.new()
	panel_light.name = "PanelAccentLight"
	panel_light.position = Vector3(0.0, 1.45, -1.25)
	panel_light.light_color = Color(1.0, 0.90, 0.75)
	panel_light.light_energy = 0.65
	panel_light.omni_range = 2.5
	panel_light.shadow_enabled = false
	add_child(panel_light)


func _create_oil_lamp(node_name: String, pos: Vector3) -> void:
	var lamp := Node3D.new()
	lamp.name = node_name
	lamp.position = pos
	add_child(lamp)
	_create_cylinder_child(lamp, Vector3(0, 0.0, 0), 0.09, 0.05, brass_material)
	_create_cylinder_child(lamp, Vector3(0, 0.06, 0), 0.04, 0.08, brass_material)
	_create_cylinder_child(lamp, Vector3(0, 0.20, 0), 0.06, 0.22, glass_material)
	_create_cylinder_child(lamp, Vector3(0, 0.34, 0), 0.05, 0.03, brass_material)

	var flame_mesh := SphereMesh.new()
	flame_mesh.radius = 0.04
	flame_mesh.height = 0.07
	flame_mesh.surface_set_material(0, lamp_glow_material)
	var flame := MeshInstance3D.new()
	flame.mesh = flame_mesh
	flame.position = Vector3(0, 0.22, 0)
	lamp.add_child(flame)

	var light := OmniLight3D.new()
	light.position = Vector3(0, 0.22, 0)
	light.light_color = Color(1.0, 0.66, 0.32)
	light.light_energy = 1.2
	light.omni_range = 2.0
	light.shadow_enabled = false
	lamp.add_child(light)


func _build_instrument_panel() -> void:
	var panel := Node3D.new()
	panel.name = "HeroInstrumentPanel"
	panel.position = panel_position
	panel.rotation_degrees = Vector3(panel_tilt_degrees, panel_rotation_degrees.y, panel_rotation_degrees.z)
	add_child(panel)

	_create_box_child(panel, "MainPlate", Vector3(0, 0.24, 0), Vector3(4.05, 0.86, 0.10), metal_material)
	_add_panel_grime(panel)
	var lower_desk := _create_box_child(panel, "LowerConsole", Vector3(0, -0.46, 0.34), Vector3(3.72, 0.12, 0.58), metal_material)
	lower_desk.rotation_degrees.x = -9.0

	var gauge_x: Array[float] = [-1.40, -0.62, 0.16, 0.94]
	var gauge_labels: Array[String] = ["VAPOR", "PRESION", "CARBON", "VEL"]
	var needle_angles: Array[float] = [-32.0, 8.0, 42.0, -88.0]
	var has_red: Array[bool] = [false, false, true, false]

	for i in range(gauge_x.size()):
		_create_gauge(panel, Vector3(gauge_x[i], 0.50, 0.13), gauge_labels[i], needle_angles[i], has_red[i])

	_create_supply_buttons(panel, Vector3(1.50, 0.08, 0.12))
	_create_label(panel, Vector3(-1.20, -0.40, 0.84), "REGULADOR", 0.0038)
	_create_label(panel, Vector3(0.95, -0.40, 0.84), "FRENO", 0.0038)


func _add_panel_grime(parent: Node3D) -> void:
	var stain_data: Array[Dictionary] = [
		{"pos": Vector3(-1.95, 0.46, 0.075), "size": Vector3(0.34, 0.09, 0.012)},
		{"pos": Vector3(-1.25, -0.04, 0.076), "size": Vector3(0.44, 0.07, 0.012)},
		{"pos": Vector3(-0.30, 0.70, 0.077), "size": Vector3(0.56, 0.06, 0.012)},
		{"pos": Vector3(0.35, -0.12, 0.078), "size": Vector3(0.34, 0.10, 0.012)},
		{"pos": Vector3(1.25, 0.07, 0.079), "size": Vector3(0.42, 0.08, 0.012)},
		{"pos": Vector3(1.85, 0.66, 0.080), "size": Vector3(0.28, 0.07, 0.012)}
	]
	for data in stain_data:
		_create_box_child(parent, "PanelGrime", data["pos"], data["size"], grime_material)


func _create_gauge(parent: Node3D, pos: Vector3, label_text: String, needle_angle: float, has_red_zone: bool) -> void:
	var ring_mesh := CylinderMesh.new()
	ring_mesh.top_radius = 0.175
	ring_mesh.bottom_radius = 0.175
	ring_mesh.height = 0.025
	ring_mesh.radial_segments = 32
	var ring := MeshInstance3D.new()
	ring.name = "%sRing" % label_text
	ring.mesh = ring_mesh
	ring.position = pos
	ring.rotation_degrees.x = 90.0
	ring.material_override = brass_material
	parent.add_child(ring)

	var face_mesh := CylinderMesh.new()
	face_mesh.top_radius = 0.145
	face_mesh.bottom_radius = 0.145
	face_mesh.height = 0.028
	face_mesh.radial_segments = 32
	var face := MeshInstance3D.new()
	face.name = "%sFace" % label_text
	face.mesh = face_mesh
	face.position = pos + Vector3(0.0, 0.0, 0.030)
	face.rotation_degrees.x = 90.0
	face.material_override = cream_face_material
	parent.add_child(face)

	var green_mesh := CylinderMesh.new()
	green_mesh.top_radius = 0.115
	green_mesh.bottom_radius = 0.115
	green_mesh.height = 0.029
	green_mesh.radial_segments = 32
	var green_inst := MeshInstance3D.new()
	green_inst.name = "%sGreen" % label_text
	green_inst.mesh = green_mesh
	green_inst.position = pos + Vector3(-0.045, 0.035, 0.043)
	green_inst.rotation_degrees.x = 90.0
	green_inst.material_override = green_zone_material
	green_inst.scale = Vector3(0.20, 0.12, 1.0)
	parent.add_child(green_inst)

	if has_red_zone:
		var red_mesh := CylinderMesh.new()
		red_mesh.top_radius = 0.115
		red_mesh.bottom_radius = 0.115
		red_mesh.height = 0.030
		red_mesh.radial_segments = 32
		var red_inst := MeshInstance3D.new()
		red_inst.name = "%sRed" % label_text
		red_inst.mesh = red_mesh
		red_inst.position = pos + Vector3(0.080, 0.010, 0.047)
		red_inst.rotation_degrees.x = 90.0
		red_inst.material_override = red_zone_material
		red_inst.scale = Vector3(0.18, 0.13, 1.0)
		parent.add_child(red_inst)

	var cap_mesh := CylinderMesh.new()
	cap_mesh.top_radius = 0.030
	cap_mesh.bottom_radius = 0.030
	cap_mesh.height = 0.032
	cap_mesh.radial_segments = 14
	var cap := MeshInstance3D.new()
	cap.name = "%sCap" % label_text
	cap.mesh = cap_mesh
	cap.position = pos + Vector3(0.0, 0.0, 0.060)
	cap.rotation_degrees.x = 90.0
	cap.material_override = brass_material
	parent.add_child(cap)

	var needle := _create_box_child(parent, "%sNeedle" % label_text, pos + Vector3(0.0, 0.0, 0.075), Vector3(0.020, 0.155, 0.014), needle_material)
	needle.rotation_degrees.z = needle_angle

	for t in range(9):
		var angle := deg_to_rad(-120.0 + float(t) * 30.0)
		var tick_r := 0.123
		_create_box_child(parent, "%sTick%d" % [label_text, t], Vector3(pos.x + cos(angle) * tick_r, pos.y + sin(angle) * tick_r, pos.z + 0.078), Vector3(0.008, 0.021, 0.007), needle_material)

	var dome_mesh := CylinderMesh.new()
	dome_mesh.top_radius = 0.147
	dome_mesh.bottom_radius = 0.147
	dome_mesh.height = 0.027
	dome_mesh.radial_segments = 32
	var dome := MeshInstance3D.new()
	dome.name = "%sGlass" % label_text
	dome.mesh = dome_mesh
	dome.position = pos + Vector3(0.0, 0.0, 0.095)
	dome.rotation_degrees.x = 90.0
	dome.material_override = glass_material
	parent.add_child(dome)
	_create_label(parent, pos + Vector3(0.0, -0.255, 0.095), label_text, 0.0029)


func _create_supply_buttons(parent: Node3D, pos: Vector3) -> void:
	_create_box_child(parent, "SupplyBG", pos + Vector3(0.0, 0.0, 0.025), Vector3(0.62, 0.30, 0.036), metal_material)
	_create_label(parent, Vector3(pos.x, pos.y + 0.10, pos.z + 0.07), "COMPRAR", 0.0028)
	_create_label(parent, Vector3(pos.x, pos.y - 0.10, pos.z + 0.07), "CARBON", 0.0028)


func _create_label(parent: Node3D, pos: Vector3, text: String, pixel_size: float) -> void:
	_create_box_child(parent, "%sPlate" % text, pos + Vector3(0.0, 0.0, 0.030), Vector3(max(0.26, float(text.length()) * 0.044), 0.064, 0.040), label_bg_material)
	var label := Label3D.new()
	label.name = "%sLabel" % text
	label.text = text
	label.font_size = 16
	label.pixel_size = pixel_size
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.modulate = Color(0.96, 0.82, 0.52)
	label.no_depth_test = true
	label.render_priority = 6
	label.outline_render_priority = 7
	label.outline_size = 1
	label.outline_modulate = Color(0.02, 0.018, 0.014)
	label.shaded = false
	label.double_sided = true
	label.position = pos + Vector3(0.0, 0.0, 0.070)
	parent.add_child(label)


func _create_box_child(parent: Node3D, node_name: String, pos: Vector3, size: Vector3, material: Material) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = mesh
	instance.position = pos
	instance.material_override = material
	parent.add_child(instance)
	return instance


func _create_cylinder_child(parent: Node3D, pos: Vector3, radius: float, height: float, material: Material) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 18
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.position = pos
	instance.material_override = material
	parent.add_child(instance)
	return instance
