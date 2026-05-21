extends Node

var last_speed: float = 0.0
var coal_is_critical: bool = false


func _ready() -> void:
	if not EventBus.train_speed_changed.is_connected(_on_train_speed_changed):
		EventBus.train_speed_changed.connect(_on_train_speed_changed)
	if not EventBus.coal_warning.is_connected(_on_coal_warning):
		EventBus.coal_warning.connect(_on_coal_warning)
	if not EventBus.whistle_requested.is_connected(_on_whistle_requested):
		EventBus.whistle_requested.connect(_on_whistle_requested)
	if not EventBus.station_timer_expired.is_connected(_on_station_timer_expired):
		EventBus.station_timer_expired.connect(_on_station_timer_expired)


func _on_train_speed_changed(speed: float) -> void:
	last_speed = speed


func _on_coal_warning(is_critical: bool) -> void:
	coal_is_critical = is_critical


func _on_whistle_requested() -> void:
	# Scene-local TrainAudioController plays the 3D whistle when audio assets exist.
	pass


func _on_station_timer_expired(_station_id: int) -> void:
	pass
