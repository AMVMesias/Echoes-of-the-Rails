class_name BuyCoalCommand
extends InteractionCommand


func execute(_value: float = 1.0) -> void:
	EventBus.buy_coal_requested.emit()
