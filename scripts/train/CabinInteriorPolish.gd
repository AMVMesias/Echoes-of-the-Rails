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

const PANEL_LAYOUT_VERSION := 5
const GAUGE_MIN_ANGLE := -115.0
const GAUGE_MAX_ANGLE := 55.0
const SPEED_GAUGE_MAX := 35.0

const GENERATED_CHILD_NAMES := {
	"WarmCabinLight": true,
	"PanelAccentLight": true,
	"CabinOilLampLeft": true,
	"CabinOilLampRight": true,
	"HeroInstrumentPanel": true,
}

# Materials
var wood_material: Material
var brass_material: Material
var dark_iron_material: Material
var cream_face_material: StandardMaterial3D
var label_bg_material: Material
var needle_material: Material
var glass_material: StandardMaterial3D
var green_zone_material: StandardMaterial3D
var red_zone_material: StandardMaterial3D
var grime_material: StandardMaterial3D
var lamp_glow_material: StandardMaterial3D
var red_handle_material: StandardMaterial3D
var brass_trim_material: Material
var plaque_material: StandardMaterial3D

# Animated needle references
var vapor_needle: Node3D
var presion_needle: Node3D
var carbon_needle: Node3D
var vel_needle: Node3D

# Animation state
var _throttle_value: float = 0.0
var _brake_value: float = 0.0
var _coal_value: float = 1.0
var _pressure_value: float = 0.0
var _speed_value: float = 0.0


func _ready() -> void:
	_ensure_generated_scene_parts()
	_bind_existing_gauge_needles()
	_apply_initial_gauge_values()
	if not Engine.is_editor_hint():
		_connect_signals()


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	var blend := 1.0 - exp(-delta * 8.0)
	_animate_needle(vapor_needle, _gauge_angle(_throttle_value), blend)
	_animate_needle(presion_needle, _gauge_angle(_pressure_value), blend)
	_animate_needle(carbon_needle, _gauge_angle(_coal_value), blend)
	_animate_needle(vel_needle, _gauge_angle(clampf(_speed_value / SPEED_GAUGE_MAX, 0.0, 1.0)), blend)


func _gauge_angle(normalized_value: float) -> float:
	return lerpf(GAUGE_MIN_ANGLE, GAUGE_MAX_ANGLE, clampf(normalized_value, 0.0, 1.0))


func _animate_needle(needle: Node3D, target_angle: float, blend: float) -> void:
	if needle == null:
		return
	needle.rotation_degrees.z = lerpf(needle.rotation_degrees.z, target_angle, blend)


func _bind_existing_gauge_needles() -> void:
	vapor_needle = _get_gauge_needle("VAPORGauge", ["vapor", "steam"])
	presion_needle = _get_gauge_needle("PRESIONGauge", ["presion", "presión", "pressure"])
	carbon_needle = _get_gauge_needle("CARBONGauge", ["carbon", "carbón", "coal"])
	vel_needle = _get_gauge_needle("VELGauge", ["vel", "speed", "velocidad"])


func _get_gauge_needle(primary_gauge_name: String, label_tokens: Array[String]) -> Node3D:
	var panel := get_node_or_null("HeroInstrumentPanel") as Node3D
	if panel == null:
		return null

	var direct := panel.get_node_or_null("%s/NeedlePivot" % primary_gauge_name) as Node3D
	if direct != null:
		return direct

	var matched_gauge := _find_gauge_by_label(panel, label_tokens)
	if matched_gauge != null:
		var matched_needle := matched_gauge.get_node_or_null("NeedlePivot") as Node3D
		if matched_needle != null:
			return matched_needle

	return null


func _find_gauge_by_label(root: Node, label_tokens: Array[String]) -> Node3D:
	for child in root.get_children():
		var child_name := child.name.to_lower()
		var name_matches := false
		for token in label_tokens:
			if child_name.contains(token):
				name_matches = true
				break
		if name_matches and child is Node3D and child.get_node_or_null("NeedlePivot") != null:
			return child as Node3D

		for grandchild in child.get_children():
			if grandchild is Label3D:
				var label := grandchild as Label3D
				var text := label.text.to_lower()
				for token in label_tokens:
					if text.contains(token):
						if child is Node3D:
							return child as Node3D
						return null

		var nested := _find_gauge_by_label(child, label_tokens)
		if nested != null:
			return nested
	return null


func _apply_initial_gauge_values() -> void:
	if vapor_needle != null:
		vapor_needle.rotation_degrees.z = _gauge_angle(_throttle_value)
	if presion_needle != null:
		presion_needle.rotation_degrees.z = _gauge_angle(_pressure_value)
	if carbon_needle != null:
		carbon_needle.rotation_degrees.z = _gauge_angle(_coal_value)
	if vel_needle != null:
		vel_needle.rotation_degrees.z = _gauge_angle(clampf(_speed_value / SPEED_GAUGE_MAX, 0.0, 1.0))


func _connect_signals() -> void:
	if not EventBus.lever_value_changed.is_connected(_on_lever_value_changed):
		EventBus.lever_value_changed.connect(_on_lever_value_changed)
	if not EventBus.coal_changed.is_connected(_on_coal_changed):
		EventBus.coal_changed.connect(_on_coal_changed)
	if not EventBus.pressure_changed.is_connected(_on_pressure_changed):
		EventBus.pressure_changed.connect(_on_pressure_changed)
	if not EventBus.train_speed_changed.is_connected(_on_speed_changed):
		EventBus.train_speed_changed.connect(_on_speed_changed)


func _on_lever_value_changed(control_name: String, value: float) -> void:
	var lower := control_name.to_lower()
	if lower.contains("steam") or lower.contains("regulator") or lower.contains("vapor"):
		_throttle_value = clampf(value, 0.0, 1.0)
	elif lower.contains("brake") or lower.contains("freno"):
		_brake_value = clampf(value, 0.0, 1.0)


func _on_coal_changed(value: float) -> void:
	_coal_value = _normalize_percent_signal(value)


func _on_pressure_changed(value: float) -> void:
	_pressure_value = _normalize_percent_signal(value)


func _on_speed_changed(speed: float) -> void:
	_speed_value = maxf(speed, 0.0)


func _normalize_percent_signal(value: float) -> float:
	if value > 1.0:
		return clampf(value / 100.0, 0.0, 1.0)
	return clampf(value, 0.0, 1.0)


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
	if build_visual_panel:
		var panel := get_node_or_null("HeroInstrumentPanel") as Node3D
		if panel == null:
			_build_instrument_panel()
		elif _panel_needs_rebuild(panel):
			_rebuild_instrument_panel(panel)
	if Engine.is_editor_hint():
		_assign_owner_to_generated_parts()
		call_deferred("_assign_owner_to_generated_parts")


func _panel_needs_rebuild(panel: Node3D) -> bool:
	if int(panel.get_meta("layout_version", 0)) < PANEL_LAYOUT_VERSION:
		return true
	var missing_vapor := panel.get_node_or_null("VAPORGauge/NeedlePivot") == null
	var missing_carbon := panel.get_node_or_null("CARBONGauge/NeedlePivot") == null
	return missing_vapor or missing_carbon


func _rebuild_instrument_panel(panel: Node3D) -> void:
	var saved_position := panel.position
	var saved_rotation := panel.rotation_degrees
	panel.free()
	_build_instrument_panel()
	var rebuilt := get_node_or_null("HeroInstrumentPanel") as Node3D
	if rebuilt == null:
		return
	rebuilt.position = saved_position
	rebuilt.rotation_degrees = saved_rotation


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


# ─── Materials ───────────────────────────────────────────────────────────────

func _create_procedural_materials() -> void:
	wood_material = _material_or_fallback("res://assets/materials/train_old_wood_weathered.tres", Color(0.22, 0.12, 0.06), 0.94, 0.0)
	brass_material = _material_or_fallback("res://assets/materials/train_aged_brass_weathered.tres", Color(0.42, 0.31, 0.16), 0.62, 0.25)
	dark_iron_material = _material_or_fallback("res://assets/materials/train_dark_iron_weathered.tres", Color(0.10, 0.04, 0.025), 0.7, 0.0)
	label_bg_material = _material_or_fallback("res://assets/materials/train_cool_black_metal.tres", Color(0.025, 0.027, 0.028), 0.86, 0.5)
	needle_material = _material_or_fallback("res://assets/materials/train_dark_iron_weathered.tres", Color(0.08, 0.03, 0.02), 0.65, 0.0)

	var face_loaded := _material_or_fallback("res://assets/materials/train_gauge_face.tres", Color(0.88, 0.83, 0.72), 0.82, 0.0)
	cream_face_material = face_loaded as StandardMaterial3D
	if cream_face_material == null:
		cream_face_material = _mat(Color(0.88, 0.83, 0.72), 0.82, 0.0)

	green_zone_material = _mat(Color(0.08, 0.28, 0.06), 0.78, 0.0)
	red_zone_material = _mat(Color(0.52, 0.06, 0.04), 0.78, 0.0)

	glass_material = _mat(Color(0.80, 0.76, 0.60, 0.35), 0.18, 0.0)
	glass_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA

	lamp_glow_material = _mat(Color(1.0, 0.72, 0.30), 0.25, 0.0)
	lamp_glow_material.emission_enabled = true
	lamp_glow_material.emission = Color(1.0, 0.56, 0.18)
	lamp_glow_material.emission_energy_multiplier = 1.8

	grime_material = _mat(Color(0.10, 0.08, 0.06), 0.96, 0.0)

	red_handle_material = _mat(Color(0.58, 0.06, 0.035), 0.62, 0.0)

	brass_trim_material = _material_or_fallback("res://assets/materials/train_aged_brass_weathered.tres", Color(0.50, 0.38, 0.18), 0.55, 0.35)

	plaque_material = _mat(Color(0.38, 0.28, 0.14), 0.68, 0.30)


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
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	return material


# ─── Lights ──────────────────────────────────────────────────────────────────

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
	panel_light.light_energy = 0.85
	panel_light.omni_range = 2.5
	panel_light.shadow_enabled = false
	add_child(panel_light)


func _create_oil_lamp(node_name: String, pos: Vector3) -> void:
	var lamp := Node3D.new()
	lamp.name = node_name
	lamp.position = pos
	add_child(lamp)

	# Base bracket (brass arm from wall)
	_create_box_child(lamp, "Bracket", Vector3(0, -0.08, 0.12), Vector3(0.04, 0.04, 0.28), brass_material)

	# Lamp base
	_create_cylinder_child(lamp, Vector3(0, 0.0, 0), 0.09, 0.05, brass_material)
	_create_cylinder_child(lamp, Vector3(0, 0.06, 0), 0.04, 0.08, brass_material)
	# Glass chimney
	_create_cylinder_child(lamp, Vector3(0, 0.20, 0), 0.06, 0.22, glass_material)
	# Top cap
	_create_cylinder_child(lamp, Vector3(0, 0.34, 0), 0.05, 0.03, brass_material)

	# Flame
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


# ─── Main Panel ──────────────────────────────────────────────────────────────

func _build_instrument_panel() -> void:
	var panel := Node3D.new()
	panel.name = "HeroInstrumentPanel"
	panel.set_meta("layout_version", PANEL_LAYOUT_VERSION)
	panel.position = panel_position
	panel.rotation_degrees = Vector3(panel_tilt_degrees, panel_rotation_degrees.y, panel_rotation_degrees.z)
	add_child(panel)

	# ── Main wood panel (weathered locomotive console) ──
	_create_box_child(panel, "MainWoodPanel", Vector3(0, 0.28, 0), Vector3(4.10, 0.98, 0.09), wood_material)

	# ── Brass trim edges ──
	_create_box_child(panel, "TrimTop", Vector3(0, 0.785, 0.018), Vector3(4.16, 0.030, 0.11), brass_trim_material)
	_create_box_child(panel, "TrimBottom", Vector3(0, -0.225, 0.018), Vector3(4.16, 0.030, 0.11), brass_trim_material)
	_create_box_child(panel, "TrimLeft", Vector3(-2.055, 0.28, 0.018), Vector3(0.030, 1.03, 0.11), brass_trim_material)
	_create_box_child(panel, "TrimRight", Vector3(2.055, 0.28, 0.018), Vector3(0.030, 1.03, 0.11), brass_trim_material)

	# ── Horizontal brass divider strip (between gauges and lower controls) ──
	_create_box_child(panel, "DividerStrip", Vector3(0, 0.075, 0.060), Vector3(3.86, 0.022, 0.045), brass_trim_material)
	_create_box_child(panel, "GaugeNameRail", Vector3(-0.20, 0.000, 0.062), Vector3(2.92, 0.040, 0.040), brass_trim_material)

	# ── Panel grime/weathering ──
	_add_panel_grime(panel)
	_add_panel_rivets(panel)

	# ── Lower console desk ──
	var lower_desk := _create_box_child(panel, "LowerConsole", Vector3(0, -0.54, 0.38), Vector3(3.70, 0.15, 0.70), wood_material)
	lower_desk.rotation_degrees.x = -7.0

	# ── Brass edge on lower console ──
	var lower_trim := _create_box_child(panel, "LowerConsoleTrim", Vector3(0, -0.455, 0.38), Vector3(3.74, 0.024, 0.72), brass_trim_material)
	lower_trim.rotation_degrees.x = -7.0

	# ── GAUGES ──
	var gauge_x: Array[float] = [-1.34, -0.54, 0.26, 1.02]
	var gauge_labels: Array[String] = ["VAPOR", "PRESIÓN", "CARBÓN", "VEL"]
	var needle_angles: Array[float] = [GAUGE_MIN_ANGLE, -55.0, GAUGE_MAX_ANGLE, GAUGE_MIN_ANGLE]
	var red_mode: Array[String] = ["none", "high", "low", "none"]

	for i in range(gauge_x.size()):
		var needle := _create_gauge(panel, Vector3(gauge_x[i], 0.43, 0.07), gauge_labels[i], needle_angles[i], red_mode[i])
		match i:
			0: vapor_needle = needle
			1: presion_needle = needle
			2: carbon_needle = needle
			3: vel_needle = needle

	# ── LEVER SLOTS ──
	_create_lever_slot(panel, Vector3(-0.85, -0.16, 0.10), "REGULADOR")
	_create_lever_slot(panel, Vector3(0.85, -0.16, 0.10), "FRENO")

	# ── Supply / Buy Coal section (upper right) ──
	_create_supply_section(panel, Vector3(1.58, 0.42, 0.08))

	# ── Bottom plaque ──
	_create_plaque(panel, Vector3(0.0, -0.14, 0.070), "CABINA DE LOCOMOTORA - VAPOR")


func _add_panel_grime(parent: Node3D) -> void:
	var stain_data: Array[Dictionary] = [
		{"pos": Vector3(-1.72, 0.60, 0.057), "size": Vector3(0.28, 0.055, 0.008)},
		{"pos": Vector3(-0.88, 0.18, 0.058), "size": Vector3(0.34, 0.045, 0.008)},
		{"pos": Vector3(0.18, 0.69, 0.059), "size": Vector3(0.42, 0.038, 0.008)},
		{"pos": Vector3(0.66, -0.055, 0.060), "size": Vector3(0.26, 0.065, 0.008)},
		{"pos": Vector3(1.48, 0.20, 0.061), "size": Vector3(0.32, 0.050, 0.008)},
	]
	for data in stain_data:
		_create_box_child(parent, "Grime", data["pos"], data["size"], grime_material)


func _add_panel_rivets(parent: Node3D) -> void:
	var xs: Array[float] = [-1.86, -1.58, -1.30, -1.02, -0.74, -0.46, -0.18, 0.10, 0.38, 0.66, 0.94, 1.22, 1.50, 1.78]
	for x in xs:
		_create_rivet(parent, Vector3(x, 0.735, 0.078), 0.018)
		_create_rivet(parent, Vector3(x, -0.175, 0.078), 0.018)
	var side_ys: Array[float] = [-0.05, 0.18, 0.41, 0.64]
	for y in side_ys:
		_create_rivet(parent, Vector3(-1.96, y, 0.080), 0.017)
		_create_rivet(parent, Vector3(1.96, y, 0.080), 0.017)


func _create_rivet(parent: Node3D, pos: Vector3, radius: float) -> void:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 1.2
	mesh.radial_segments = 8
	mesh.rings = 4
	mesh.surface_set_material(0, brass_trim_material)
	var rivet := MeshInstance3D.new()
	rivet.name = "Rivet"
	rivet.mesh = mesh
	rivet.position = pos
	parent.add_child(rivet)


# ─── Gauge ───────────────────────────────────────────────────────────────────

func _create_gauge(parent: Node3D, pos: Vector3, label_text: String, needle_angle: float, red_mode: String) -> Node3D:
	var gauge_root := Node3D.new()
	gauge_root.name = "%sGauge" % _safe_node_name(label_text)
	gauge_root.position = pos
	parent.add_child(gauge_root)

	# Outer brass bezel ring
	var bezel_mesh := TorusMesh.new()
	bezel_mesh.inner_radius = 0.138
	bezel_mesh.outer_radius = 0.188
	bezel_mesh.rings = 32
	bezel_mesh.ring_segments = 20
	var bezel := MeshInstance3D.new()
	bezel.name = "Bezel"
	bezel.mesh = bezel_mesh
	bezel.rotation_degrees.x = 90.0
	bezel.position = Vector3(0, 0, 0.02)
	bezel.material_override = brass_material
	gauge_root.add_child(bezel)

	# Face disc (cream colored)
	var face_mesh := CylinderMesh.new()
	face_mesh.top_radius = 0.148
	face_mesh.bottom_radius = 0.148
	face_mesh.height = 0.014
	face_mesh.radial_segments = 40
	var face := MeshInstance3D.new()
	face.name = "Face"
	face.mesh = face_mesh
	face.position = Vector3(0, 0, 0.015)
	face.rotation_degrees.x = 90.0
	face.material_override = cream_face_material
	gauge_root.add_child(face)

	# Colored warning bands. Coal has the red band at the empty side.
	if red_mode == "low":
		_create_sector_child(gauge_root, "RedLowBand", 0.102, 0.135, -115.0, -76.0, 0.026, red_zone_material)
		_create_sector_child(gauge_root, "SafeBand", 0.102, 0.135, -68.0, 55.0, 0.025, green_zone_material)
	elif red_mode == "high":
		_create_sector_child(gauge_root, "SafeBand", 0.102, 0.135, -115.0, 15.0, 0.025, green_zone_material)
		_create_sector_child(gauge_root, "RedHighBand", 0.102, 0.135, 22.0, 55.0, 0.026, red_zone_material)
	else:
		_create_sector_child(gauge_root, "SafeBand", 0.102, 0.135, -115.0, 55.0, 0.025, green_zone_material)

	# Center cap (brass pivot)
	var cap_mesh := CylinderMesh.new()
	cap_mesh.top_radius = 0.022
	cap_mesh.bottom_radius = 0.022
	cap_mesh.height = 0.018
	cap_mesh.radial_segments = 14
	var cap := MeshInstance3D.new()
	cap.name = "Cap"
	cap.mesh = cap_mesh
	cap.position = Vector3(0, 0, 0.035)
	cap.rotation_degrees.x = 90.0
	cap.material_override = brass_material
	gauge_root.add_child(cap)

	# Needle (animatable)
	var needle_pivot := Node3D.new()
	needle_pivot.name = "NeedlePivot"
	needle_pivot.position = Vector3(0, 0, 0.038)
	needle_pivot.rotation_degrees.z = needle_angle
	gauge_root.add_child(needle_pivot)

	var needle_box := BoxMesh.new()
	needle_box.size = Vector3(0.014, 0.126, 0.008)
	var needle_inst := MeshInstance3D.new()
	needle_inst.name = "Needle"
	needle_inst.mesh = needle_box
	needle_inst.position = Vector3(0, 0.063, 0)
	needle_inst.material_override = needle_material
	needle_pivot.add_child(needle_inst)

	var counterweight_mesh := BoxMesh.new()
	counterweight_mesh.size = Vector3(0.018, 0.040, 0.009)
	var counterweight := MeshInstance3D.new()
	counterweight.name = "Counterweight"
	counterweight.mesh = counterweight_mesh
	counterweight.position = Vector3(0, -0.020, 0)
	counterweight.material_override = needle_material
	needle_pivot.add_child(counterweight)

	# Tick marks
	for t in range(9):
		var angle_degrees := GAUGE_MIN_ANGLE + float(t) * ((GAUGE_MAX_ANGLE - GAUGE_MIN_ANGLE) / 8.0)
		var angle := deg_to_rad(angle_degrees)
		var tick_r := 0.120
		var tick_box := BoxMesh.new()
		tick_box.size = Vector3(0.006, 0.018, 0.005)
		var tick := MeshInstance3D.new()
		tick.name = "Tick%d" % t
		tick.mesh = tick_box
		tick.position = Vector3(cos(angle) * tick_r, sin(angle) * tick_r, 0.028)
		tick.rotation_degrees.z = angle_degrees - 90.0
		tick.material_override = needle_material
		gauge_root.add_child(tick)

	var numbers := ["0", "50", "100"]
	if label_text == "VEL":
		numbers = ["0", "20", "40"]
	_create_dial_number(gauge_root, numbers[0], GAUGE_MIN_ANGLE, 0.088)
	_create_dial_number(gauge_root, numbers[1], -30.0, 0.094)
	_create_dial_number(gauge_root, numbers[2], GAUGE_MAX_ANGLE, 0.088)
	_create_face_label(gauge_root, label_text)

	# Glass dome cover
	var dome_mesh := CylinderMesh.new()
	dome_mesh.top_radius = 0.148
	dome_mesh.bottom_radius = 0.148
	dome_mesh.height = 0.016
	dome_mesh.radial_segments = 32
	var dome := MeshInstance3D.new()
	dome.name = "Glass"
	dome.mesh = dome_mesh
	dome.position = Vector3(0, 0, 0.048)
	dome.rotation_degrees.x = 90.0
	dome.material_override = glass_material
	gauge_root.add_child(dome)

	# Label below gauge
	_create_brass_label(parent, pos + Vector3(0, -0.235, 0.050), label_text, 0.0027)

	return needle_pivot


func _create_sector_child(parent: Node3D, node_name: String, inner_radius: float, outer_radius: float, start_degrees: float, end_degrees: float, z: float, material: Material) -> MeshInstance3D:
	var segments := 14
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var uvs := PackedVector2Array()
	var indices := PackedInt32Array()

	for i in range(segments + 1):
		var t := float(i) / float(segments)
		var angle := deg_to_rad(lerpf(start_degrees, end_degrees, t))
		var inner := Vector3(cos(angle) * inner_radius, sin(angle) * inner_radius, z)
		var outer := Vector3(cos(angle) * outer_radius, sin(angle) * outer_radius, z)
		vertices.append(inner)
		vertices.append(outer)
		normals.append(Vector3.FORWARD)
		normals.append(Vector3.FORWARD)
		uvs.append(Vector2(0.0, t))
		uvs.append(Vector2(1.0, t))

	for i in range(segments):
		var base := i * 2
		indices.append(base)
		indices.append(base + 1)
		indices.append(base + 2)
		indices.append(base + 1)
		indices.append(base + 3)
		indices.append(base + 2)

	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices

	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)

	var sector := MeshInstance3D.new()
	sector.name = node_name
	sector.mesh = mesh
	sector.material_override = material
	parent.add_child(sector)
	return sector


func _create_dial_number(parent: Node3D, text: String, angle_degrees: float, radius: float) -> void:
	var angle := deg_to_rad(angle_degrees)
	var label := Label3D.new()
	label.name = "Dial%s" % text
	label.text = text
	label.font_size = 11
	label.pixel_size = 0.00145
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.modulate = Color(0.12, 0.09, 0.055)
	label.outline_size = 0
	label.shaded = false
	label.double_sided = true
	label.no_depth_test = false
	label.position = Vector3(cos(angle) * radius, sin(angle) * radius, 0.053)
	parent.add_child(label)


func _create_face_label(parent: Node3D, text: String) -> void:
	var label := Label3D.new()
	label.name = "FaceLabel"
	label.text = text
	label.font_size = 12
	label.pixel_size = 0.00155
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.modulate = Color(0.12, 0.09, 0.055)
	label.outline_size = 0
	label.shaded = false
	label.double_sided = true
	label.no_depth_test = false
	label.position = Vector3(0.0, -0.082, 0.053)
	parent.add_child(label)


# ─── Lever Slot ──────────────────────────────────────────────────────────────

func _create_lever_slot(parent: Node3D, pos: Vector3, label_text: String) -> void:
	# Slot cutout (dark iron inset)
	_create_box_child(parent, "%sSlot" % label_text, pos, Vector3(0.105, 0.34, 0.065), dark_iron_material)
	_create_box_child(parent, "%sGuideTop" % label_text, pos + Vector3(0, 0.18, 0.026), Vector3(0.26, 0.032, 0.035), brass_trim_material)
	_create_box_child(parent, "%sGuideBot" % label_text, pos + Vector3(0, -0.18, 0.026), Vector3(0.26, 0.032, 0.035), brass_trim_material)

	# Position indicator plates
	_create_brass_label(parent, pos + Vector3(0.22, 0.15, 0.035), "ABIERTO", 0.0019)
	_create_brass_label(parent, pos + Vector3(0.22, -0.15, 0.035), "CERRADO", 0.0019)

	# Main label plate below the slot
	_create_brass_label(parent, pos + Vector3(0, -0.295, 0.035), label_text, 0.0031)


# ─── Supply Section ──────────────────────────────────────────────────────────

func _create_supply_section(parent: Node3D, pos: Vector3) -> void:
	# Background plate for the real buy-coal interaction.
	_create_box_child(parent, "SupplyBG", pos, Vector3(0.54, 0.35, 0.045), brass_trim_material)
	_create_box_child(parent, "SupplyInset", pos + Vector3(0, 0, 0.030), Vector3(0.48, 0.28, 0.020), label_bg_material)

	# Labels
	_create_brass_label(parent, pos + Vector3(0, 0.075, 0.055), "COMPRAR", 0.0022)
	_create_brass_label(parent, pos + Vector3(0, -0.085, 0.055), "CARBÓN", 0.0022)


# ─── Plaque ──────────────────────────────────────────────────────────────────

func _create_plaque(parent: Node3D, pos: Vector3, text: String) -> void:
	var plaque_width := maxf(0.60, float(text.length()) * 0.038)
	_create_box_child(parent, "PlaqueBG", pos, Vector3(plaque_width + 0.06, 0.065, 0.025), plaque_material)

	# Brass edge around plaque
	_create_box_child(parent, "PlaqueEdgeTop", pos + Vector3(0, 0.035, 0.005), Vector3(plaque_width + 0.08, 0.006, 0.028), brass_trim_material)
	_create_box_child(parent, "PlaqueEdgeBot", pos + Vector3(0, -0.035, 0.005), Vector3(plaque_width + 0.08, 0.006, 0.028), brass_trim_material)

	var label := Label3D.new()
	label.name = "PlaqueLabel"
	label.text = text
	label.font_size = 12
	label.pixel_size = 0.0024
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.modulate = Color(0.92, 0.78, 0.42)
	label.no_depth_test = false
	label.render_priority = 6
	label.outline_render_priority = 7
	label.outline_size = 1
	label.outline_modulate = Color(0.02, 0.015, 0.01)
	label.shaded = false
	label.double_sided = true
	label.position = pos + Vector3(0, 0, 0.025)
	parent.add_child(label)


# ─── Brass Label ─────────────────────────────────────────────────────────────

func _create_brass_label(parent: Node3D, pos: Vector3, text: String, pixel_size: float) -> void:
	var label_width := maxf(0.20, float(text.length()) * 0.036)
	var safe_name := _safe_node_name(text)
	_create_box_child(parent, "%sPlate" % safe_name, pos, Vector3(label_width, 0.050, 0.022), brass_trim_material)

	var label := Label3D.new()
	label.name = "%sLbl" % safe_name
	label.text = text
	label.font_size = 14
	label.pixel_size = pixel_size
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.modulate = Color(0.14, 0.10, 0.06)
	label.no_depth_test = false
	label.render_priority = 6
	label.outline_render_priority = 7
	label.outline_size = 1
	label.outline_modulate = Color(0.90, 0.78, 0.46, 0.55)
	label.shaded = false
	label.double_sided = true
	label.position = pos + Vector3(0, 0, 0.018)
	parent.add_child(label)


func _safe_node_name(text: String) -> String:
	return text.replace("Á", "A").replace("É", "E").replace("Í", "I").replace("Ó", "O").replace("Ú", "U").replace("Ñ", "N").replace(" ", "")


# ─── Primitives ──────────────────────────────────────────────────────────────

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
