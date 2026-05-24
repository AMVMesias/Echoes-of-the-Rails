class_name TrainVisualControls
extends Node

@export var visual_root_path: NodePath = NodePath("../TrainVisual")

var visual_root: Node
var throttle_pivot: Node3D
var brake_pivot: Node3D
var pneumatic_pivot: Node3D
var steam_needle: Node3D
var brake_needle: Node3D
var coal_needle: Node3D
var speed_needle: Node3D
var wheel_nodes: Array[Node3D] = []

var throttle_value: float = 0.0
var brake_value: float = 0.0
var coal_value: float = 1.0
var pressure_value: float = 0.0
var speed_value: float = 0.0


func _ready() -> void:
	visual_root = get_node_or_null(visual_root_path)
	if visual_root == null:
		visual_root = get_parent()

	throttle_pivot = _find_visual("ThrottleLeverPivot")
	brake_pivot = _find_visual("BrakeLeverPivot")
	pneumatic_pivot = _find_visual("PneumaticLeverPivot")
	steam_needle = _find_visual("SteamNeedle")
	brake_needle = _find_visual("BrakeNeedle")
	coal_needle = _find_visual("CoalNeedle")
	speed_needle = _find_visual("SpeedNeedle")
	_collect_wheels()

	if not EventBus.lever_value_changed.is_connected(_on_lever_value_changed):
		EventBus.lever_value_changed.connect(_on_lever_value_changed)
	if not EventBus.coal_changed.is_connected(_on_coal_changed):
		EventBus.coal_changed.connect(_on_coal_changed)
	if not EventBus.pressure_changed.is_connected(_on_pressure_changed):
		EventBus.pressure_changed.connect(_on_pressure_changed)
	if not EventBus.train_speed_changed.is_connected(_on_train_speed_changed):
		EventBus.train_speed_changed.connect(_on_train_speed_changed)


func _process(delta: float) -> void:
	var blend: float = 1.0 - exp(-delta * 10.0)
	_set_x_angle(throttle_pivot, lerpf(-18.0, 32.0, throttle_value), blend)
	_set_x_angle(brake_pivot, lerpf(-10.0, 42.0, brake_value), blend)
	_set_x_angle(pneumatic_pivot, lerpf(-8.0, 34.0, brake_value), blend)
	_set_z_angle(steam_needle, lerpf(-120.0, 35.0, throttle_value), blend)
	_set_z_angle(brake_needle, lerpf(-105.0, 45.0, brake_value), blend)
	_set_z_angle(coal_needle, lerpf(-110.0, 50.0, coal_value), blend)
	_set_z_angle(speed_needle, lerpf(-120.0, 60.0, clampf(speed_value / 35.0, 0.0, 1.0)), blend)

	for wheel in wheel_nodes:
		wheel.rotate_x(-speed_value * delta * 0.75)


func _set_x_angle(node: Node3D, target: float, blend: float) -> void:
	if node == null:
		return
	node.rotation_degrees.x = lerpf(node.rotation_degrees.x, target, blend)


func _set_z_angle(node: Node3D, target: float, blend: float) -> void:
	if node == null:
		return
	node.rotation_degrees.z = lerpf(node.rotation_degrees.z, target, blend)


func _on_lever_value_changed(control_name: String, value: float) -> void:
	var normalized_value: float = clampf(value, 0.0, 1.0)
	var lower_name := control_name.to_lower()
	if lower_name.contains("steam") or lower_name.contains("regulator") or lower_name.contains("vapor"):
		throttle_value = normalized_value
	elif lower_name.contains("brake") or lower_name.contains("freno"):
		brake_value = normalized_value


func _on_coal_changed(value: float) -> void:
	coal_value = clampf(value, 0.0, 1.0)


func _on_pressure_changed(value: float) -> void:
	pressure_value = clampf(value, 0.0, 1.0)


func _on_train_speed_changed(speed: float) -> void:
	speed_value = maxf(speed, 0.0)


func _collect_wheels() -> void:
	wheel_nodes.clear()
	if visual_root == null:
		return
	var wheels_root := visual_root.find_child("WheelPivots", true, false)
	if wheels_root == null:
		return
	for child in wheels_root.get_children():
		if child is Node3D:
			wheel_nodes.append(child as Node3D)


func _find_visual(node_name: String) -> Node3D:
	if visual_root == null:
		return null
	return visual_root.find_child(node_name, true, false) as Node3D
