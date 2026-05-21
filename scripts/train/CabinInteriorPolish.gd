class_name CabinInteriorPolish
extends Node3D

## Builds the realistic locomotive cabin interior procedurally.
## Uses StandardMaterial3D for small detail parts (brass bezels, gauge faces,
## needles, handles) to preserve metallic/roughness properties.
## Uses PSX shader .tres materials only for large structural surfaces.

@export var build_visual_panel: bool = true

# --- PSX materials loaded from .tres (large surfaces only) ---
var rusted_metal_mat: Material
var iron_mat: Material

# --- StandardMaterial3D (small details with proper shading) ---
var brass_material: StandardMaterial3D
var dark_face_material: StandardMaterial3D
var label_bg_material: StandardMaterial3D
var needle_material: StandardMaterial3D
var lamp_glow_material: StandardMaterial3D
var glass_material: StandardMaterial3D
var dark_slot_material: StandardMaterial3D
var green_zone_material: StandardMaterial3D
var red_zone_material: StandardMaterial3D
var white_tick_material: StandardMaterial3D
var cream_face_material: StandardMaterial3D
var metal_material: StandardMaterial3D


func _ready() -> void:
	_load_materials()
	_create_procedural_materials()
	_add_interior_lighting()
	_add_oil_lamps()
	if build_visual_panel:
		_build_instrument_panel()


# ─── Material Loading ────────────────────────────────────────────────

func _load_materials() -> void:
	rusted_metal_mat = load("res://assets/materials/psx_rusted_metal.tres")
	iron_mat = load("res://assets/materials/psx_iron.tres")


func _create_procedural_materials() -> void:
	# Brass – muted gold, not too bright
	brass_material = _mat(Color(0.50, 0.38, 0.20), 0.55, 0.25)

	# Panel metal surface (procedural, darker than PSX version)
	metal_material = _mat(Color(0.32, 0.29, 0.24), 0.78, 0.25)

	# Dark gauge face – nearly black
	dark_face_material = _mat(Color(0.06, 0.055, 0.05), 0.90, 0.0)

	# Cream face for clock
	cream_face_material = _mat(Color(0.85, 0.80, 0.68), 0.85, 0.0)

	# Label background plates
	label_bg_material = _mat(Color(0.03, 0.025, 0.02), 0.88, 0.0)

	# Needle – dark reddish brown
	needle_material = _mat(Color(0.10, 0.04, 0.025), 0.7, 0.0)

	# Dark slot material
	dark_slot_material = _mat(Color(0.04, 0.035, 0.03), 0.92, 0.0)

	# Green zone (safe area on gauges)
	green_zone_material = _mat(Color(0.10, 0.35, 0.08), 0.75, 0.0)

	# Red zone (danger area on carbon gauge)
	red_zone_material = _mat(Color(0.50, 0.06, 0.04), 0.75, 0.0)

	# White tick marks
	white_tick_material = _mat(Color(0.82, 0.78, 0.62), 0.80, 0.0)

	# Transparent glass
	glass_material = _mat(Color(0.78, 0.74, 0.58, 0.40), 0.20, 0.0)
	glass_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA

	# Lamp flame glow
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


# ─── Interior Lighting ───────────────────────────────────────────────

func _add_interior_lighting() -> void:
	# Warm ceiling light – REDUCED energy to avoid red blow-out
	var ceiling := OmniLight3D.new()
	ceiling.name = "WarmCabinLight"
	ceiling.position = Vector3(0.0, 2.85, 0.0)
	ceiling.light_color = Color(1.0, 0.88, 0.72)
	ceiling.light_energy = 2.5
	ceiling.omni_range = 7.0
	ceiling.shadow_enabled = false
	add_child(ceiling)

	# Panel accent light – subtle
	var panel_light := OmniLight3D.new()
	panel_light.name = "PanelAccentLight"
	panel_light.position = Vector3(0.0, 1.60, -2.10)
	panel_light.light_color = Color(1.0, 0.90, 0.75)
	panel_light.light_energy = 1.0
	panel_light.omni_range = 2.5
	panel_light.shadow_enabled = false
	add_child(panel_light)


# ─── Oil Lamps ───────────────────────────────────────────────────────

func _add_oil_lamps() -> void:
	_create_oil_lamp(Vector3(-2.05, 1.55, -2.50))
	_create_oil_lamp(Vector3(2.05, 1.55, -2.50))


func _create_oil_lamp(pos: Vector3) -> void:
	var lamp := Node3D.new()
	lamp.name = "CabinOilLamp"
	lamp.position = pos
	add_child(lamp)

	# Brass base
	_create_cylinder_child(lamp, Vector3(0, 0.0, 0), 0.09, 0.05, brass_material)
	# Brass pedestal
	_create_cylinder_child(lamp, Vector3(0, 0.06, 0), 0.04, 0.08, brass_material)
	# Glass chimney
	_create_cylinder_child(lamp, Vector3(0, 0.20, 0), 0.06, 0.22, glass_material)
	# Brass cap
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

	# Warm point light
	var light := OmniLight3D.new()
	light.position = Vector3(0, 0.22, 0)
	light.light_color = Color(1.0, 0.66, 0.32)
	light.light_energy = 1.2
	light.omni_range = 2.0
	light.shadow_enabled = false
	lamp.add_child(light)


# ─── Main Instrument Panel ──────────────────────────────────────────

func _build_instrument_panel() -> void:
	var panel := Node3D.new()
	panel.name = "HeroInstrumentPanel"
	panel.position = Vector3(0.0, 1.20, -1.55)
	panel.rotation_degrees.x = -6.0
	panel.scale = Vector3(1.06, 1.06, 1.06)
	add_child(panel)

	# ── Main metal plate ──
	_create_box_child(panel, "MainPlate", Vector3(0, 0.22, 0), Vector3(4.35, 1.05, 0.12), metal_material)

	# ── Lower desk plate ──
	var lower_desk := _create_box_child(panel, "LowerDesk", Vector3(0, -0.55, 0.46), Vector3(4.35, 0.14, 1.08), metal_material)
	lower_desk.rotation_degrees.x = -16.0

	# ── Gauges: VAPOR, VAPOR, CARBÓN ──
	var gauge_x: Array[float] = [-1.55, -0.72, 0.12]
	var gauge_labels: Array[String] = ["VAPOR", "VAPOR", "CARBÓN"]
	var needle_angles: Array[float] = [-32.0, -10.0, 42.0]
	var has_red: Array[bool] = [false, false, true]

	for i in range(gauge_x.size()):
		_create_gauge(panel, Vector3(gauge_x[i], 0.42, 0.09), gauge_labels[i], needle_angles[i], has_red[i])

	# ── Station Clock (right side, larger) ──
	_create_station_clock(panel, Vector3(1.25, 0.42, 0.09))

	# ── Supply Buttons ──
	_create_supply_buttons(panel, Vector3(0.78, 0.42, 0.12))

	# ── Lever labels on lower desk ──
	_create_label(panel, Vector3(-1.35, -0.76, 0.88), "REGULADOR DE VAPOR", 0.0048)
	_create_label(panel, Vector3(1.10, -0.76, 0.88), "FRENO NEUMÁTICO", 0.0048)

	# ── Visual lever slots on lower desk ──
	_create_visual_lever(panel, Vector3(-1.35, -0.67, 0.64), "REGULADOR")
	_create_visual_lever(panel, Vector3(1.10, -0.67, 0.64), "FRENO")

	# ── Rivets ──
	_create_rivets(panel)


# ─── Gauge ──────────────────────────────────────────────────────────

func _create_gauge(parent: Node3D, pos: Vector3, label_text: String, needle_angle: float, has_red_zone: bool) -> void:
	# Brass outer bezel – THIN ring, not thick cylinder
	var ring_mesh := CylinderMesh.new()
	ring_mesh.top_radius = 0.245
	ring_mesh.bottom_radius = 0.245
	ring_mesh.height = 0.025
	ring_mesh.radial_segments = 32
	var ring := MeshInstance3D.new()
	ring.name = "%sRing" % label_text
	ring.mesh = ring_mesh
	ring.position = pos
	ring.rotation_degrees.x = 90.0
	ring.material_override = brass_material
	parent.add_child(ring)

	# Dark gauge face – sits IN FRONT of bezel
	var face_mesh := CylinderMesh.new()
	face_mesh.top_radius = 0.205
	face_mesh.bottom_radius = 0.205
	face_mesh.height = 0.028
	face_mesh.radial_segments = 32
	var face := MeshInstance3D.new()
	face.name = "%sFace" % label_text
	face.mesh = face_mesh
	face.position = pos + Vector3(0.0, 0.0, 0.030)
	face.rotation_degrees.x = 90.0
	face.material_override = dark_face_material
	parent.add_child(face)

	# Green zone (small indicator)
	var green_mesh := CylinderMesh.new()
	green_mesh.top_radius = 0.165
	green_mesh.bottom_radius = 0.165
	green_mesh.height = 0.029
	green_mesh.radial_segments = 32
	var green_inst := MeshInstance3D.new()
	green_inst.name = "%sGreen" % label_text
	green_inst.mesh = green_mesh
	green_inst.position = pos + Vector3(-0.04, 0.0, 0.040)
	green_inst.rotation_degrees.x = 90.0
	green_inst.material_override = green_zone_material
	green_inst.scale = Vector3(0.28, 0.28, 1.0)
	parent.add_child(green_inst)

	# Red zone on CARBÓN gauge
	if has_red_zone:
		var red_mesh := CylinderMesh.new()
		red_mesh.top_radius = 0.165
		red_mesh.bottom_radius = 0.165
		red_mesh.height = 0.030
		red_mesh.radial_segments = 32
		var red_inst := MeshInstance3D.new()
		red_inst.name = "%sRed" % label_text
		red_inst.mesh = red_mesh
		red_inst.position = pos + Vector3(0.08, 0.0, 0.044)
		red_inst.rotation_degrees.x = 90.0
		red_inst.material_override = red_zone_material
		red_inst.scale = Vector3(0.22, 0.22, 1.0)
		parent.add_child(red_inst)

	# Center pivot cap
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

	# Needle
	var needle := _create_box_child(parent, "%sNeedle" % label_text, pos + Vector3(0.0, 0.0, 0.075), Vector3(0.028, 0.22, 0.016), needle_material)
	needle.rotation_degrees.z = needle_angle

	# Tick marks
	for t in range(9):
		var angle := deg_to_rad(-120.0 + float(t) * 30.0)
		var tick_r := 0.175
		var tx := pos.x + cos(angle) * tick_r
		var ty := pos.y + sin(angle) * tick_r
		_create_box_child(parent, "%sTick%d" % [label_text, t], Vector3(tx, ty, pos.z + 0.078), Vector3(0.010, 0.028, 0.008), white_tick_material)

	# Glass dome
	var dome_mesh := CylinderMesh.new()
	dome_mesh.top_radius = 0.21
	dome_mesh.bottom_radius = 0.21
	dome_mesh.height = 0.027
	dome_mesh.radial_segments = 32
	var dome := MeshInstance3D.new()
	dome.name = "%sGlass" % label_text
	dome.mesh = dome_mesh
	dome.position = pos + Vector3(0.0, 0.0, 0.095)
	dome.rotation_degrees.x = 90.0
	dome.material_override = glass_material
	parent.add_child(dome)

	# Label under gauge
	_create_label(parent, pos + Vector3(0.0, -0.34, 0.095), label_text, 0.0048)


# ─── Station Clock ──────────────────────────────────────────────────

func _create_station_clock(parent: Node3D, pos: Vector3) -> void:
	# Larger brass bezel – thin
	var ring_mesh := CylinderMesh.new()
	ring_mesh.top_radius = 0.30
	ring_mesh.bottom_radius = 0.30
	ring_mesh.height = 0.025
	ring_mesh.radial_segments = 36
	var ring := MeshInstance3D.new()
	ring.name = "ClockBezel"
	ring.mesh = ring_mesh
	ring.position = pos
	ring.rotation_degrees.x = 90.0
	ring.material_override = brass_material
	parent.add_child(ring)

	# Cream clock face
	var face_mesh := CylinderMesh.new()
	face_mesh.top_radius = 0.255
	face_mesh.bottom_radius = 0.255
	face_mesh.height = 0.028
	face_mesh.radial_segments = 36
	var face := MeshInstance3D.new()
	face.name = "ClockFace"
	face.mesh = face_mesh
	face.position = pos + Vector3(0.0, 0.0, 0.030)
	face.rotation_degrees.x = 90.0
	face.material_override = cream_face_material
	parent.add_child(face)

	# Hour marks (12)
	for h in range(12):
		var angle := deg_to_rad(float(h) * 30.0)
		var mark_r := 0.21
		var mx := pos.x + cos(angle) * mark_r
		var my := pos.y + sin(angle) * mark_r
		var mark_size := Vector3(0.014, 0.040, 0.008) if (h % 3 == 0) else Vector3(0.008, 0.025, 0.006)
		_create_box_child(parent, "ClockMark%d" % h, Vector3(mx, my, pos.z + 0.078), mark_size, needle_material)

	# Hour hand
	_create_box_child(parent, "HourHand", pos + Vector3(0.02, 0.0, 0.080), Vector3(0.018, 0.12, 0.010), needle_material)
	# Minute hand
	var min_h := _create_box_child(parent, "MinHand", pos + Vector3(-0.01, 0.0, 0.090), Vector3(0.014, 0.16, 0.008), needle_material)
	min_h.rotation_degrees.z = 72.0

	# Center cap
	var cap_mesh := CylinderMesh.new()
	cap_mesh.top_radius = 0.022
	cap_mesh.bottom_radius = 0.022
	cap_mesh.height = 0.032
	cap_mesh.radial_segments = 12
	var cap := MeshInstance3D.new()
	cap.name = "ClockCap"
	cap.mesh = cap_mesh
	cap.position = pos + Vector3(0.0, 0.0, 0.105)
	cap.rotation_degrees.x = 90.0
	cap.material_override = brass_material
	parent.add_child(cap)

	# Label
	_create_label(parent, pos + Vector3(0.0, -0.40, 0.10), "RELOJ DE ESTACIÓN", 0.0042)


# ─── Supply Buttons ─────────────────────────────────────────────────

func _create_supply_buttons(parent: Node3D, pos: Vector3) -> void:
	_create_box_child(parent, "SupplyBG", pos + Vector3(0.0, 0.0, 0.0), Vector3(0.96, 0.06, 0.22), dark_slot_material)

	_create_label(parent, Vector3(pos.x, pos.y + 0.16, pos.z + 0.08), "COMPRAR CARBÓN", 0.006)
	_create_label(parent, Vector3(pos.x, pos.y - 0.02, pos.z + 0.08), "COMPRAR", 0.006)
	_create_label(parent, Vector3(pos.x, pos.y - 0.20, pos.z + 0.08), "RECONTRAER", 0.006)


# ─── Visual Lever (decorative slots on lower desk) ──────────────────

func _create_visual_lever(parent: Node3D, pos: Vector3, lever_name: String) -> void:
	# Slot groove
	var slot := _create_box_child(parent, "%sSlot" % lever_name, pos + Vector3(0.0, 0.0, 0.0), Vector3(0.66, 0.06, 0.18), dark_slot_material)
	slot.rotation_degrees.x = -18.0

	# Stick
	var stick_mesh := CylinderMesh.new()
	stick_mesh.top_radius = 0.035
	stick_mesh.bottom_radius = 0.035
	stick_mesh.height = 0.62
	stick_mesh.radial_segments = 10
	var stick := MeshInstance3D.new()
	stick.name = "%sStick" % lever_name
	stick.mesh = stick_mesh
	stick.position = pos + Vector3(0.22, 0.10, 0.08)
	stick.rotation_degrees = Vector3(72.0, 0.0, 90.0)
	stick.material_override = metal_material
	parent.add_child(stick)

	# Red handle ball
	var handle_mat := _mat(Color(0.58, 0.06, 0.035), 0.62, 0.0)
	var handle_mesh := SphereMesh.new()
	handle_mesh.radius = 0.105
	handle_mesh.height = 0.18
	handle_mesh.surface_set_material(0, handle_mat)
	var handle := MeshInstance3D.new()
	handle.name = "%sHandle" % lever_name
	handle.mesh = handle_mesh
	handle.position = pos + Vector3(0.50, 0.16, 0.10)
	parent.add_child(handle)


# ─── Rivets ─────────────────────────────────────────────────────────

func _create_rivets(parent: Node3D) -> void:
	for x_i in range(17):
		var x: float = -1.72 + float(x_i) * 0.215
		_create_rivet(parent, Vector3(x, 0.74, 0.09))
		_create_rivet(parent, Vector3(x, -0.26, 0.10))
	for y_i in range(5):
		var y: float = -0.16 + float(y_i) * 0.18
		_create_rivet(parent, Vector3(-2.02, y, 0.10))
		_create_rivet(parent, Vector3(2.02, y, 0.10))


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


# ─── Label ──────────────────────────────────────────────────────────

func _create_label(parent: Node3D, pos: Vector3, text: String, pixel_size: float) -> void:
	_create_box_child(parent, "%sPlate" % text, pos + Vector3(0.0, 0.0, 0.030), Vector3(max(0.34, float(text.length()) * 0.058), 0.070, 0.045), label_bg_material)
	var label := Label3D.new()
	label.name = "%sLabel" % text
	label.text = text
	label.font_size = 24
	label.pixel_size = pixel_size
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.modulate = Color(0.92, 0.82, 0.64)
	label.position = pos + Vector3(0.0, 0.0, 0.070)
	label.rotation_degrees = Vector3.ZERO
	parent.add_child(label)


# ─── Helpers ────────────────────────────────────────────────────────

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
