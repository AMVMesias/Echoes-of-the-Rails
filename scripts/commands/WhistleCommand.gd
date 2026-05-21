class_name WhistleCommand
extends InteractionCommand


func execute(_value: float = 1.0) -> void:
	EventBus.whistle_requested.emit()
