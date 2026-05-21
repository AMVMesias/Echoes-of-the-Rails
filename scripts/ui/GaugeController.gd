class_name GaugeController
extends Node3D

@export_enum("coal", "pressure", "speed", "station_timer", "derailment") var signal_name: String = "coal"
@export var needle_path: NodePath = NodePath("Needle")
@export var min_value: float = 0.0
@export var max_value: float = 100.0
@export var min_angle: float = -115.0
@export var max_angle: float = 115.0
@export var invert_value: bool = false

@onready var needle: Node3D = get_node_or_null(needle_path) as Node3D


func _ready() -> void:
	match signal_name:
		"coal":
			EventBus.coal_changed.connect(_on_value_changed)
		"pressure":
			EventBus.pressure_changed.connect(_on_value_changed)
		"speed":
			EventBus.train_speed_changed.connect(_on_value_changed)
		"station_timer":
			EventBus.station_timer_changed.connect(_on_station_timer_changed)
		"derailment":
			EventBus.derailment_risk_changed.connect(_on_value_changed)


func update_needle(value: float) -> void:
	if needle == null:
		return
	var normalized := inverse_lerp(min_value, max_value, value)
	if invert_value:
		normalized = 1.0 - normalized
	normalized = clamp(normalized, 0.0, 1.0)
	needle.rotation_degrees.z = lerp(min_angle, max_angle, normalized)


func _on_value_changed(value: float) -> void:
	update_needle(value)


func _on_station_timer_changed(_station_id: int, remaining_time: float) -> void:
	update_needle(remaining_time)
