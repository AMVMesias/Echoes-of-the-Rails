extends Node

const SAVE_PATH := "user://echoes_last_run_results.json"

var last_results: Dictionary = {}


func save_results(results: Dictionary) -> void:
	last_results = results.duplicate(true)
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("Could not open save file: %s" % SAVE_PATH)
		return
	file.store_string(JSON.stringify(last_results, "\t"))


func load_results() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {}

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return {}

	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) == TYPE_DICTIONARY:
		last_results = parsed
		return last_results.duplicate(true)

	return {}
