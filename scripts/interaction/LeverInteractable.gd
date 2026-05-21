class_name LeverInteractable
extends Interactable

@export var control_name: String = "SteamRegulator"
@export var min_value: float = 0.0
@export var max_value: float = 1.0
@export var value_step: float = 0.1
@export var current_value: float = 0.0:
	set(value):
		_set_value_internal(value)
	get:
		return _current_value

var _current_value: float = 0.0
var _visual_pivot: Node3D


func _ready() -> void:
	super()
	_visual_pivot = get_node_or_null("Pivot") as Node3D
	set_value(current_value)


func interact() -> void:
	set_value(current_value + value_step)
	if is_equal_approx(current_value, max_value):
		value_step = -abs(value_step)
	elif is_equal_approx(current_value, min_value):
		value_step = abs(value_step)


func set_value(value: float) -> void:
	_set_value_internal(value)
	var normalized := inverse_lerp(min_value, max_value, _current_value)
	if _visual_pivot != null:
		_visual_pivot.rotation_degrees.x = lerp(-35.0, 35.0, normalized)
	EventBus.lever_value_changed.emit(control_name, normalized)


func _set_value_internal(value: float) -> void:
	_current_value = clamp(value, min_value, max_value)
