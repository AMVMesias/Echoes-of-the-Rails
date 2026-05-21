class_name TrainAudioController
extends Node3D

@export var max_speed: float = 35.0

@onready var engine_audio: AudioStreamPlayer3D = get_node_or_null("EngineLoop") as AudioStreamPlayer3D
@onready var wind_audio: AudioStreamPlayer3D = get_node_or_null("WindFog") as AudioStreamPlayer3D
@onready var whistle_audio: AudioStreamPlayer3D = get_node_or_null("Whistle") as AudioStreamPlayer3D
@onready var coal_warning_audio: AudioStreamPlayer3D = get_node_or_null("CoalWarning") as AudioStreamPlayer3D


func _ready() -> void:
	if not EventBus.train_speed_changed.is_connected(update_engine_audio):
		EventBus.train_speed_changed.connect(update_engine_audio)
	if not EventBus.whistle_requested.is_connected(play_whistle):
		EventBus.whistle_requested.connect(play_whistle)
	if not EventBus.coal_warning.is_connected(_on_coal_warning):
		EventBus.coal_warning.connect(_on_coal_warning)


func update_engine_audio(speed: float) -> void:
	var normalized: float = clampf(speed / max(max_speed, 0.1), 0.0, 1.0)
	if engine_audio != null:
		engine_audio.pitch_scale = lerp(0.8, 1.6, normalized)
		engine_audio.volume_db = lerp(-18.0, -3.0, normalized)
		if engine_audio.stream != null and not engine_audio.playing:
			engine_audio.play()
	if wind_audio != null:
		wind_audio.volume_db = lerp(-28.0, -10.0, normalized)
		if wind_audio.stream != null and not wind_audio.playing:
			wind_audio.play()


func play_whistle() -> void:
	if whistle_audio != null and whistle_audio.stream != null:
		whistle_audio.play()


func _on_coal_warning(is_critical: bool) -> void:
	if coal_warning_audio == null or coal_warning_audio.stream == null:
		return
	if is_critical and not coal_warning_audio.playing:
		coal_warning_audio.play()
	elif not is_critical and coal_warning_audio.playing:
		coal_warning_audio.stop()
