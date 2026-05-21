class_name SupplyPanel
extends Node3D

@onready var feedback_label: Label3D = get_node_or_null("FeedbackPlate") as Label3D


func _ready() -> void:
	if not EventBus.coal_purchase_failed.is_connected(_on_purchase_failed):
		EventBus.coal_purchase_failed.connect(_on_purchase_failed)
	if not EventBus.coal_changed.is_connected(_on_coal_changed):
		EventBus.coal_changed.connect(_on_coal_changed)


func _on_purchase_failed(reason: String) -> void:
	if feedback_label != null:
		feedback_label.text = reason


func _on_coal_changed(value: float) -> void:
	if feedback_label != null:
		feedback_label.text = "COAL %03d" % int(round(value))
