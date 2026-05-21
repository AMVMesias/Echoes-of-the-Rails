class_name BrakeCommand
extends InteractionCommand


func execute(value: float = 1.0) -> void:
	EventBus.lever_value_changed.emit("BrakeLever", clamp(value, 0.0, 1.0))
