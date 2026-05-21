class_name DerailmentSystem
extends Node

const TRAIN_CONFIG_PATH := "res://resources/configs/TrainConfig.tres"

@export var train_config: TrainConfig
@export var risk_decay: float = 0.7

var risk: float = 0.0


func _ready() -> void:
	if train_config == null:
		train_config = _load_train_config()


func evaluate(speed: float, in_curve: bool, delta: float) -> void:
	if in_curve and speed > train_config.derailment_curve_speed:
		var excess := (speed - train_config.derailment_curve_speed) / max(train_config.derailment_curve_speed, 0.1)
		risk += (0.45 + excess) * delta
	else:
		risk = max(0.0, risk - risk_decay * delta)

	var normalized_risk := clamp(risk / max(train_config.derailment_time_limit, 0.1), 0.0, 1.0)
	EventBus.derailment_risk_changed.emit(normalized_risk)

	if risk >= train_config.derailment_time_limit:
		EventBus.game_over.emit("DERAILED")


func reset() -> void:
	risk = 0.0
	EventBus.derailment_risk_changed.emit(0.0)


func _load_train_config() -> TrainConfig:
	if ResourceLoader.exists(TRAIN_CONFIG_PATH):
		var loaded := load(TRAIN_CONFIG_PATH)
		if loaded is TrainConfig:
			return loaded
	return TrainConfig.new()
