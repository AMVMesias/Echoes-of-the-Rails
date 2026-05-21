class_name DiaryFactory
extends RefCounted


func entry_for_station(entries: Array, station_id: int) -> DiaryEntry:
	for entry in entries:
		if entry is DiaryEntry and entry.station_id == station_id:
			return entry
	return null
