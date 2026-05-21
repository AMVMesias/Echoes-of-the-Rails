class_name EmergencyConsumption
extends FuelConsumptionStrategy


func calculate_consumption(base_consumption: float, throttle: float, speed: float, route_factor: float) -> float:
	return base_consumption + throttle * max(speed, 1.0) * 0.011 * route_factor
