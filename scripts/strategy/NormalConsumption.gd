class_name NormalConsumption
extends FuelConsumptionStrategy


func calculate_consumption(base_consumption: float, throttle: float, speed: float, route_factor: float) -> float:
	return base_consumption + throttle * max(speed, 1.0) * 0.004 * route_factor
