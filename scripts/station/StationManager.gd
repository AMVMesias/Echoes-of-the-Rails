class_name StationManager
extends Node3D

const STATION_CONFIG_PATH := "res://resources/configs/StationConfig.tres"

@export var track_path: NodePath
@export var train_path: NodePath
@export var station_scene: PackedScene
@export var station_config: StationConfig
@export var generated_station_distances: Array[float] = [180.0, 470.0, 790.0, 1190.0, 1620.0]
@export var base_passengers_per_station: int = 3

var stations: Array[Station] = []
var active_station_index: int = -1
var route_number: int = 0
var approach_announced: bool = false

@onready var track_node: Path3D = get_node_or_null(track_path) as Path3D
@onready var train: TrainController = get_node_or_null(train_path) as TrainController


func _ready() -> void:
	if station_config == null:
		station_config = _load_station_config()
	if station_scene == null and ResourceLoader.exists("res://scenes/station/Station.tscn"):
		station_scene = load("res://scenes/station/Station.tscn")

	call_deferred("_initialize_stations")


func _process(delta: float) -> void:
	if active_station_index < 0 or active_station_index >= stations.size():
		return
	if train == null:
		train = get_node_or_null(train_path) as TrainController
		if train == null:
			return

	var station := stations[active_station_index]
	if station.tick_timer(delta):
		_lose_station(station, "TIME_EXPIRED")
		return

	var distance_to_station := station.distance_on_route - train.distance_along_path
	if not approach_announced and distance_to_station <= station_config.approach_distance and distance_to_station >= 0.0:
		approach_announced = true
		EventBus.station_approached.emit(station.station_id)

	if abs(distance_to_station) <= station_config.stop_distance_threshold:
		if train.current_speed <= station_config.stop_speed_threshold and train.is_stopped:
			_complete_station(station)
	elif distance_to_station < -station_config.stop_distance_threshold:
		_lose_station(station, "PASSED_PLATFORM")


func _initialize_stations() -> void:
	_collect_existing_stations()
	if stations.is_empty():
		_generate_stations()
	_activate_station(0)


func _collect_existing_stations() -> void:
	stations.clear()
	for child in get_children():
		if child is Station:
			stations.append(child)
	stations.sort_custom(func(a: Station, b: Station) -> bool: return a.distance_on_route < b.distance_on_route)


func _generate_stations() -> void:
	if station_scene == null:
		return

	var index := 0
	for distance in generated_station_distances:
		var route_distance: float = distance
		var station := station_scene.instantiate() as Station
		if station == null:
			continue
		var wait_ratio: float = float(index) / max(float(generated_station_distances.size() - 1), 1.0)
		var wait_time: float = lerpf(station_config.min_wait_time, station_config.max_wait_time, wait_ratio)
		var passengers: int = base_passengers_per_station + index
		station.configure(index + 1, route_distance, wait_time, passengers, true)
		add_child(station)
		stations.append(station)
		_position_station_on_track(station)
		index += 1


func _position_station_on_track(station: Station) -> void:
	if track_node == null or track_node.curve == null:
		station.position = Vector3(4.0, 0.0, -station.distance_on_route)
		return

	var point := track_node.curve.sample_baked(station.distance_on_route)
	var next_point := track_node.curve.sample_baked(station.distance_on_route + 2.0)
	var direction := (next_point - point).normalized()
	var side := direction.cross(Vector3.UP).normalized()
	if side.length() < 0.01:
		side = Vector3.RIGHT
	station.global_position = track_node.to_global(point + side * 5.0 + Vector3.UP * 0.2)
	station.look_at(track_node.to_global(point + direction), Vector3.UP)


func _activate_station(index: int) -> void:
	if index >= stations.size():
		EventBus.game_over.emit("ROUTES_COMPLETED")
		return

	active_station_index = index
	approach_announced = false
	var station := stations[active_station_index]
	station.set_active(true)
	ScoreManager.register_station_visit()


func _complete_station(station: Station) -> void:
	if station.was_completed or station.was_lost:
		return
	if station.remaining_time <= 0.0:
		_lose_station(station, "TIME_EXPIRED")
		return

	station.complete()
	ScoreManager.register_station_success()
	EventBus.train_arrived_at_station.emit(station.station_id)
	EventBus.passengers_boarded.emit(station.passengers_count)
	if station.has_diary_fragment:
		DiaryManager.unlock_diary_for_station(station.station_id)

	route_number += 1
	EventBus.route_completed.emit(route_number)
	_activate_station(active_station_index + 1)


func _lose_station(station: Station, reason: String) -> void:
	if station.was_completed or station.was_lost:
		return
	station.passengers_leave(reason)
	EventBus.station_timer_expired.emit(station.station_id)
	_activate_station(active_station_index + 1)


func _load_station_config() -> StationConfig:
	if ResourceLoader.exists(STATION_CONFIG_PATH):
		var loaded := load(STATION_CONFIG_PATH)
		if loaded is StationConfig:
			return loaded
	return StationConfig.new()
