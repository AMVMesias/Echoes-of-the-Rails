class_name FuelSystem
extends Node

const BALANCE_PATH := "res://resources/configs/GameBalanceConfig.tres"

@export var balance_config: GameBalanceConfig
@export var consumption_strategy: FuelConsumptionStrategy
@export var base_consumption: float = 0.015
@export var route_factor: float = 1.0

var current_coal: float = 100.0
var max_coal: float = 100.0
var critical_coal_level: float = 15.0
var is_critical: bool = false


func _ready() -> void:
	if balance_config == null:
		balance_config = _load_balance_config()
	if consumption_strategy == null:
		consumption_strategy = NormalConsumption.new()
	reset()

	if not EventBus.buy_coal_requested.is_connected(buy_coal):
		EventBus.buy_coal_requested.connect(buy_coal)


func reset() -> void:
	max_coal = balance_config.max_coal
	critical_coal_level = balance_config.coal_warning_level
	current_coal = clamp(balance_config.starting_coal, 0.0, max_coal)
	_emit_coal()


func has_fuel() -> bool:
	return current_coal > 0.0


func consume_fuel(delta: float, throttle: float, speed: float) -> void:
	if current_coal <= 0.0:
		return

	var consumption := 0.0
	if speed > 0.05 or throttle > 0.01:
		consumption = consumption_strategy.calculate_consumption(base_consumption, throttle, speed, route_factor)

	current_coal = clamp(current_coal - consumption * delta, 0.0, max_coal)
	_emit_coal()

	if current_coal <= 0.0:
		EventBus.game_over.emit("OUT_OF_COAL")


func buy_coal() -> void:
	if current_coal >= max_coal:
		EventBus.coal_purchase_failed.emit("COAL_ALREADY_FULL")
		return

	if not ScoreManager.spend_points(balance_config.coal_purchase_cost):
		EventBus.coal_purchase_failed.emit("NOT_ENOUGH_POINTS")
		return

	current_coal = min(max_coal, current_coal + balance_config.coal_purchase_amount)
	_emit_coal()


func _emit_coal() -> void:
	EventBus.coal_changed.emit(current_coal)
	var next_critical := current_coal <= critical_coal_level
	if next_critical != is_critical:
		is_critical = next_critical
		EventBus.coal_warning.emit(is_critical)


func _load_balance_config() -> GameBalanceConfig:
	if ResourceLoader.exists(BALANCE_PATH):
		var loaded := load(BALANCE_PATH)
		if loaded is GameBalanceConfig:
			return loaded
	return GameBalanceConfig.new()
