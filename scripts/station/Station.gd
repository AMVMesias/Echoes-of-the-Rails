class_name Station
extends Node3D

@export var station_id: int = 1
@export var distance_on_route: float = 0.0
@export var time_limit: float = 90.0
@export var passengers_count: int = 3
@export var has_diary_fragment: bool = true

var remaining_time: float = 90.0
var is_active: bool = false
var was_completed: bool = false
var was_lost: bool = false

@onready var passengers_root: Node3D = get_node_or_null("Passengers") as Node3D
@onready var fog_effect: FogVolume = get_node_or_null("FogEffect") as FogVolume


func _ready() -> void:
	remaining_time = time_limit
	set_active(false)


func configure(new_id: int, route_distance: float, limit: float, passenger_amount: int, diary_enabled: bool) -> void:
	station_id = new_id
	distance_on_route = route_distance
	time_limit = limit
	remaining_time = limit
	passengers_count = passenger_amount
	has_diary_fragment = diary_enabled
	was_completed = false
	was_lost = false


func set_active(value: bool) -> void:
	is_active = value
	if value:
		remaining_time = time_limit
	EventBus.station_timer_changed.emit(station_id, remaining_time)


func tick_timer(delta: float) -> bool:
	if not is_active or was_completed or was_lost:
		return false

	remaining_time = max(0.0, remaining_time - delta)
	EventBus.station_timer_changed.emit(station_id, remaining_time)
	return remaining_time <= 0.0


func complete() -> void:
	if was_completed or was_lost:
		return
	was_completed = true
	is_active = false
	_board_passengers()


func passengers_leave(reason: String = "TIME_EXPIRED") -> void:
	if was_completed or was_lost:
		return
	was_lost = true
	is_active = false
	_fade_passengers_to_fog()
	if fog_effect != null:
		fog_effect.visible = true
	EventBus.station_lost.emit(station_id, reason)


func _board_passengers() -> void:
	if passengers_root == null:
		return
	for child in passengers_root.get_children():
		if child is Passenger:
			child.board()


func _fade_passengers_to_fog() -> void:
	if passengers_root == null:
		return
	for child in passengers_root.get_children():
		if child is Passenger:
			child.leave_in_fog()
