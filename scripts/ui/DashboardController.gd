class_name DashboardController
extends Node3D

@onready var score_label: Label3D = get_node_or_null("ScorePlate") as Label3D
@onready var state_label: Label3D = get_node_or_null("StatePlate") as Label3D


func _ready() -> void:
	if score_label != null:
		score_label.text = "PTS 0"
	if state_label != null:
		state_label.text = "TRAVELING"

	if not EventBus.score_changed.is_connected(_on_score_changed):
		EventBus.score_changed.connect(_on_score_changed)
	if not EventBus.game_state_changed.is_connected(_on_game_state_changed):
		EventBus.game_state_changed.connect(_on_game_state_changed)


func _on_score_changed(points: int) -> void:
	if score_label != null:
		score_label.text = "PTS %d" % points


func _on_game_state_changed(state_name: String) -> void:
	if state_label != null:
		state_label.text = state_name
