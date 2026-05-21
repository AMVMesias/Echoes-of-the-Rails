class_name BrakeSystem
extends Node

const TRAIN_CONFIG_PATH := "res://resources/configs/TrainConfig.tres"

@export var train_config: TrainConfig
@export var brake_response: float = 1.0


func _ready() -> void:
	if train_config == null:
		train_config = _load_train_config()


func apply_brake(current_speed: float, brake_input: float, delta: float) -> float:
	var brake_force: float = train_config.brake_force * brake_response * clampf(brake_input, 0.0, 1.0)
	return max(0.0, current_speed - brake_force * delta)


func get_brake_force(brake_input: float) -> float:
	return train_config.brake_force * brake_response * clampf(brake_input, 0.0, 1.0)


func _load_train_config() -> TrainConfig:
	if ResourceLoader.exists(TRAIN_CONFIG_PATH):
		var loaded := load(TRAIN_CONFIG_PATH)
		if loaded is TrainConfig:
			return loaded
	return TrainConfig.new()
