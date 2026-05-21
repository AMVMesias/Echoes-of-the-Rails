class_name SteamRegulatorCommand
extends InteractionCommand


func execute(value: float = 1.0) -> void:
	EventBus.lever_value_changed.emit("SteamRegulator", clamp(value, 0.0, 1.0))
