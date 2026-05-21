extends Node

const BALANCE_PATH := "res://resources/configs/GameBalanceConfig.tres"

var balance_config: GameBalanceConfig
var points: int = 0
var routes_completed: int = 0
var passengers_transported: int = 0
var diaries_unlocked: Array[String] = []
var stations_visited: int = 0
var stations_successful: int = 0


func _ready() -> void:
	balance_config = _load_balance_config()
	reset()

	if not EventBus.passengers_boarded.is_connected(add_passengers):
		EventBus.passengers_boarded.connect(add_passengers)
	if not EventBus.route_completed.is_connected(_on_route_completed):
		EventBus.route_completed.connect(_on_route_completed)
	if not EventBus.diary_unlocked.is_connected(_on_diary_unlocked):
		EventBus.diary_unlocked.connect(_on_diary_unlocked)


func reset() -> void:
	points = 0
	routes_completed = 0
	passengers_transported = 0
	diaries_unlocked.clear()
	stations_visited = 0
	stations_successful = 0
	EventBus.score_changed.emit(points)


func register_station_visit() -> void:
	stations_visited += 1


func register_station_success() -> void:
	stations_successful += 1
	points += balance_config.punctuality_bonus
	EventBus.score_changed.emit(points)


func add_passengers(amount: int) -> void:
	if amount <= 0:
		return
	passengers_transported += amount
	points += amount * balance_config.points_per_passenger
	EventBus.score_changed.emit(points)


func spend_points(cost: int) -> bool:
	if cost <= 0:
		return true
	if points < cost:
		return false
	points -= cost
	EventBus.score_changed.emit(points)
	return true


func get_punctuality_percentage() -> float:
	if stations_visited <= 0:
		return 0.0
	return (float(stations_successful) / float(stations_visited)) * 100.0


func get_results() -> Dictionary:
	return {
		"points": points,
		"routes_completed": routes_completed,
		"passengers_transported": passengers_transported,
		"diaries_unlocked": diaries_unlocked.duplicate(),
		"diary_count": diaries_unlocked.size(),
		"stations_visited": stations_visited,
		"stations_successful": stations_successful,
		"punctuality_percentage": get_punctuality_percentage()
	}


func _load_balance_config() -> GameBalanceConfig:
	if ResourceLoader.exists(BALANCE_PATH):
		var loaded := load(BALANCE_PATH)
		if loaded is GameBalanceConfig:
			return loaded
	return GameBalanceConfig.new()


func _on_route_completed(route_number: int) -> void:
	routes_completed = max(routes_completed, route_number)


func _on_diary_unlocked(diary_id: String) -> void:
	if diary_id.is_empty() or diaries_unlocked.has(diary_id):
		return
	diaries_unlocked.append(diary_id)
