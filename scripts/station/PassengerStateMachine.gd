class_name PassengerStateMachine
extends RefCounted

enum State {
	WAITING,
	BOARDING,
	LEFT_IN_FOG
}

var current_state: int = State.WAITING


func set_state(next_state: int) -> void:
	current_state = next_state


func state_to_string() -> String:
	for key in State.keys():
		if State[key] == current_state:
			return key
	return "UNKNOWN"
