extends Node

signal coal_changed(value: float)
signal coal_warning(is_critical: bool)
signal pressure_changed(value: float)
signal pressure_warning(value: float)
signal train_speed_changed(speed: float)
signal derailment_risk_changed(value: float)

signal station_approached(station_id: int)
signal station_timer_changed(station_id: int, remaining_time: float)
signal station_timer_expired(station_id: int)
signal train_arrived_at_station(station_id: int)
signal station_lost(station_id: int, reason: String)

signal passengers_boarded(amount: int)
signal route_completed(route_number: int)
signal diary_unlocked(diary_id: String)
signal score_changed(points: int)

signal buy_coal_requested()
signal coal_purchase_failed(reason: String)
signal whistle_requested()
signal lever_value_changed(control_name: String, value: float)

signal game_state_changed(state_name: String)
signal game_over(reason: String)
signal final_results_updated(results: Dictionary)
