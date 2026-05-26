class_name NormalConsumption
extends FuelConsumptionStrategy


func calculate_consumption(base_consumption: float, throttle: float, speed: float, route_factor: float) -> float:
	var throttle_burn: float = throttle * (2.8 + maxf(speed, 0.0) * 0.22)
	return (base_consumption + throttle_burn) * route_factor
