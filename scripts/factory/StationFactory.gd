class_name StationFactory
extends RefCounted


func create_station(station_scene: PackedScene, station_id: int, distance: float, time_limit: float, passengers: int, has_diary: bool) -> Station:
	if station_scene == null:
		return null
	var station := station_scene.instantiate() as Station
	if station != null:
		station.configure(station_id, distance, time_limit, passengers, has_diary)
	return station
