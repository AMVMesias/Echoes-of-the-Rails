extends Node

enum GameState {
	GAME_START,
	TRAVELING,
	APPROACHING_STATION,
	STOPPED_AT_STATION,
	BOARDING_PASSENGERS,
	ROUTE_COMPLETED,
	OUT_OF_COAL,
	DERAILED,
	GAME_OVER
}

const BALANCE_PATH := "res://resources/configs/GameBalanceConfig.tres"

var current_state: int = GameState.GAME_START
var state_machine := GameStateMachine.new()
var balance_config: GameBalanceConfig
var game_over_reason: String = ""


func _ready() -> void:
	balance_config = _load_balance_config()
	state_machine.configure(GameState.GAME_START, _build_transitions())
	state_machine.state_changed.connect(_on_state_machine_changed)

	if not EventBus.game_over.is_connected(_on_game_over):
		EventBus.game_over.connect(_on_game_over)
	if not EventBus.route_completed.is_connected(_on_route_completed):
		EventBus.route_completed.connect(_on_route_completed)
	if not EventBus.station_approached.is_connected(_on_station_approached):
		EventBus.station_approached.connect(_on_station_approached)
	if not EventBus.train_arrived_at_station.is_connected(_on_train_arrived_at_station):
		EventBus.train_arrived_at_station.connect(_on_train_arrived_at_station)

	call_deferred("start_game")


func start_game() -> void:
	game_over_reason = ""
	set_state(GameState.TRAVELING)


func set_state(next_state: int) -> void:
	if state_machine.transition_to(next_state):
		current_state = next_state
		EventBus.game_state_changed.emit(state_to_string(current_state))


func finish_game(reason: String) -> void:
	if current_state == GameState.GAME_OVER:
		return

	game_over_reason = reason
	match reason:
		"OUT_OF_COAL":
			set_state(GameState.OUT_OF_COAL)
		"DERAILED":
			set_state(GameState.DERAILED)
		_:
			set_state(GameState.GAME_OVER)

	set_state(GameState.GAME_OVER)
	var results := ScoreManager.get_results()
	results["end_reason"] = reason
	EventBus.final_results_updated.emit(results)
	SaveManager.save_results(results)


func state_to_string(state: int) -> String:
	for key in GameState.keys():
		if GameState[key] == state:
			return key
	return "UNKNOWN"


func _load_balance_config() -> GameBalanceConfig:
	if ResourceLoader.exists(BALANCE_PATH):
		var loaded := load(BALANCE_PATH)
		if loaded is GameBalanceConfig:
			return loaded
	return GameBalanceConfig.new()


func _build_transitions() -> Dictionary:
	return {
		GameState.GAME_START: [GameState.TRAVELING, GameState.GAME_OVER],
		GameState.TRAVELING: [GameState.APPROACHING_STATION, GameState.OUT_OF_COAL, GameState.DERAILED, GameState.GAME_OVER],
		GameState.APPROACHING_STATION: [GameState.STOPPED_AT_STATION, GameState.TRAVELING, GameState.OUT_OF_COAL, GameState.DERAILED],
		GameState.STOPPED_AT_STATION: [GameState.BOARDING_PASSENGERS, GameState.TRAVELING, GameState.GAME_OVER],
		GameState.BOARDING_PASSENGERS: [GameState.ROUTE_COMPLETED, GameState.TRAVELING, GameState.GAME_OVER],
		GameState.ROUTE_COMPLETED: [GameState.TRAVELING, GameState.GAME_OVER],
		GameState.OUT_OF_COAL: [GameState.GAME_OVER],
		GameState.DERAILED: [GameState.GAME_OVER],
		GameState.GAME_OVER: []
	}


func _on_state_machine_changed(_previous_state: int, next_state: int) -> void:
	current_state = next_state


func _on_game_over(reason: String) -> void:
	finish_game(reason)


func _on_route_completed(route_number: int) -> void:
	set_state(GameState.ROUTE_COMPLETED)
	if route_number >= balance_config.required_routes_to_win:
		finish_game("ROUTES_COMPLETED")
	else:
		call_deferred("set_state", GameState.TRAVELING)


func _on_station_approached(_station_id: int) -> void:
	set_state(GameState.APPROACHING_STATION)


func _on_train_arrived_at_station(_station_id: int) -> void:
	set_state(GameState.STOPPED_AT_STATION)
	call_deferred("set_state", GameState.BOARDING_PASSENGERS)
