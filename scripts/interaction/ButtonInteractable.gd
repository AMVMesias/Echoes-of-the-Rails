class_name ButtonInteractable
extends Interactable

@export_enum("BUY_COAL", "WHISTLE") var command_name: String = "BUY_COAL"
@export var command: InteractionCommand


func interact() -> void:
	if command != null:
		command.execute()
		return

	match command_name:
		"BUY_COAL":
			EventBus.buy_coal_requested.emit()
		"WHISTLE":
			EventBus.whistle_requested.emit()
