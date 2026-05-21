class_name PressureSystem
extends Node

@export var max_pressure: float = 100.0
@export var idle_pressure: float = 35.0
@export var pressure_rise_rate: float = 30.0
@export var pressure_fall_rate: float = 20.0
@export var warning_pressure: float = 85.0

var current_pressure: float = 35.0
var warning_active: bool = false


func _ready() -> void:
	current_pressure = idle_pressure
	EventBus.pressure_changed.emit(current_pressure)


func update_pressure(delta: float, throttle: float, brake_input: float) -> void:
	var target_pressure := lerp(idle_pressure, max_pressure, clamp(throttle, 0.0, 1.0))
	if brake_input > 0.05:
		target_pressure = max(idle_pressure * 0.7, target_pressure - brake_input * 25.0)

	var rate := pressure_rise_rate if target_pressure > current_pressure else pressure_fall_rate
	current_pressure = move_toward(current_pressure, target_pressure, rate * delta)
	current_pressure = clamp(current_pressure, 0.0, max_pressure)
	EventBus.pressure_changed.emit(current_pressure)

	var next_warning := current_pressure >= warning_pressure
	if next_warning != warning_active:
		warning_active = next_warning
		if warning_active:
			EventBus.pressure_warning.emit(current_pressure)
