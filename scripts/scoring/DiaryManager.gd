extends Node

var entries_by_station: Dictionary = {}
var unlocked_entries: Dictionary = {}


func _ready() -> void:
	load_entries()


func load_entries() -> void:
	entries_by_station.clear()
	var dir := DirAccess.open("res://resources/diaries")
	if dir == null:
		return

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".tres"):
			var entry := load("res://resources/diaries/%s" % file_name)
			if entry is DiaryEntry:
				entries_by_station[entry.station_id] = entry
		file_name = dir.get_next()
	dir.list_dir_end()


func unlock_diary_for_station(station_id: int) -> String:
	if not entries_by_station.has(station_id):
		return ""

	var entry: DiaryEntry = entries_by_station[station_id]
	if unlocked_entries.has(entry.diary_id):
		return entry.diary_id

	unlocked_entries[entry.diary_id] = entry
	EventBus.diary_unlocked.emit(entry.diary_id)
	return entry.diary_id


func get_unlocked_entries() -> Array:
	return unlocked_entries.values()
