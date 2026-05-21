class_name GameStateMachine
extends RefCounted

signal state_changed(previous_state: int, next_state: int)

var current_state: int = 0
var allowed_transitions: Dictionary = {}


func configure(initial_state: int, transitions: Dictionary) -> void:
	current_state = initial_state
	allowed_transitions = transitions


func can_transition_to(next_state: int) -> bool:
	if allowed_transitions.is_empty():
		return true

	if not allowed_transitions.has(current_state):
		return true

	var allowed: Array = allowed_transitions[current_state]
	return allowed.has(next_state)


func transition_to(next_state: int) -> bool:
	if current_state == next_state:
		return true

	if not can_transition_to(next_state):
		return false

	var previous_state := current_state
	current_state = next_state
	state_changed.emit(previous_state, next_state)
	return true
