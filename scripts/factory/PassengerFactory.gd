class_name PassengerFactory
extends RefCounted


func create_passenger(passenger_scene: PackedScene, data: PassengerData = null) -> Passenger:
	if passenger_scene == null:
		return null
	var passenger := passenger_scene.instantiate() as Passenger
	if passenger != null:
		passenger.passenger_data = data
	return passenger
