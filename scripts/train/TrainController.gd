class_name TrainController
extends PathFollow3D

const TRAIN_CONFIG_PATH := "res://resources/configs/TrainConfig.tres"

@export var train_config: TrainConfig
@export var desktop_test_controls: bool = true
@export var progress_loop: bool = false
@export var curve_check_period: float = 190.0
@export var curve_check_start: float = 65.0
@export var curve_check_end: float = 135.0

var current_speed: float = 0.0
var max_speed: float = 35.0
var acceleration_input: float = 0.0
var brake_input: float = 0.0
var distance_along_path: float = 0.0
var is_stopped: bool = true

@onready var fuel_system: FuelSystem = get_node_or_null("FuelSystem") as FuelSystem
@onready var brake_system: BrakeSystem = get_node_or_null("BrakeSystem") as BrakeSystem
@onready var pressure_system: PressureSystem = get_node_or_null("PressureSystem") as PressureSystem
@onready var derailment_system: DerailmentSystem = get_node_or_null("DerailmentSystem") as DerailmentSystem


func _ready() -> void:
	if train_config == null:
		train_config = _load_train_config()
	max_speed = train_config.max_speed
	loop = progress_loop

	if not EventBus.lever_value_changed.is_connected(_on_lever_value_changed):
		EventBus.lever_value_changed.connect(_on_lever_value_changed)

	EventBus.train_speed_changed.emit(current_speed)


func _physics_process(delta: float) -> void:
	if desktop_test_controls:
		_update_desktop_test_controls(delta)

	_update_speed(delta)
	_move_along_track(delta)
	_check_derailment_risk(delta)

	if fuel_system != null:
		fuel_system.consume_fuel(delta, acceleration_input, current_speed)
	if pressure_system != null:
		pressure_system.update_pressure(delta, acceleration_input, brake_input)

	EventBus.train_speed_changed.emit(current_speed)


func set_throttle(value: float) -> void:
	acceleration_input = clamp(value, 0.0, 1.0)


func set_brake(value: float) -> void:
	brake_input = clamp(value, 0.0, 1.0)


func _update_speed(delta: float) -> void:
	var usable_throttle := acceleration_input
	if fuel_system != null and not fuel_system.has_fuel():
		usable_throttle = 0.0

	var acceleration := usable_throttle * train_config.acceleration_force
	current_speed += acceleration * delta

	if brake_system != null:
		current_speed = brake_system.apply_brake(current_speed, brake_input, delta)
	else:
		current_speed = max(0.0, current_speed - train_config.brake_force * brake_input * delta)

	var drag := train_config.drag_force * delta
	current_speed = max(0.0, current_speed - drag)
	current_speed = clamp(current_speed, 0.0, max_speed)
	is_stopped = current_speed <= 0.08


func _move_along_track(delta: float) -> void:
	distance_along_path += current_speed * delta

	var parent_path := get_parent() as Path3D
	if parent_path != null and parent_path.curve != null:
		var length := parent_path.curve.get_baked_length()
		if length > 0.0:
			if progress_loop:
				distance_along_path = fposmod(distance_along_path, length)
			else:
				distance_along_path = clamp(distance_along_path, 0.0, length)

	progress = distance_along_path


func _check_derailment_risk(delta: float) -> void:
	if derailment_system == null:
		return
	derailment_system.evaluate(current_speed, _is_in_curve_zone(), delta)


func _is_in_curve_zone() -> bool:
	var local_progress := fposmod(distance_along_path, curve_check_period)
	return local_progress >= curve_check_start and local_progress <= curve_check_end


func _on_lever_value_changed(control_name: String, value: float) -> void:
	var lowered := control_name.to_lower()
	if lowered.contains("steam") or lowered.contains("throttle") or lowered.contains("regulator"):
		set_throttle(value)
	elif lowered.contains("brake") or lowered.contains("freno"):
		set_brake(value)


func _update_desktop_test_controls(delta: float) -> void:
	if Input.is_key_pressed(KEY_W):
		EventBus.lever_value_changed.emit("SteamRegulator", clampf(acceleration_input + delta, 0.0, 1.0))
		EventBus.lever_value_changed.emit("BrakeLever", clampf(brake_input - delta * 1.4, 0.0, 1.0))
	if Input.is_key_pressed(KEY_S):
		EventBus.lever_value_changed.emit("SteamRegulator", clampf(acceleration_input - delta, 0.0, 1.0))
		EventBus.lever_value_changed.emit("BrakeLever", clampf(brake_input + delta * 1.7, 0.0, 1.0))
	if Input.is_key_pressed(KEY_D):
		EventBus.lever_value_changed.emit("BrakeLever", clampf(brake_input + delta, 0.0, 1.0))
	if Input.is_key_pressed(KEY_A):
		EventBus.lever_value_changed.emit("BrakeLever", clampf(brake_input - delta, 0.0, 1.0))
	if Input.is_key_pressed(KEY_B):
		EventBus.buy_coal_requested.emit()
	if Input.is_key_pressed(KEY_H):
		EventBus.whistle_requested.emit()


func _load_train_config() -> TrainConfig:
	if ResourceLoader.exists(TRAIN_CONFIG_PATH):
		var loaded := load(TRAIN_CONFIG_PATH)
		if loaded is TrainConfig:
			return loaded
	return TrainConfig.new()
