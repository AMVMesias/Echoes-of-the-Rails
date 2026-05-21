class_name HighSpeedConsumption
extends FuelConsumptionStrategy


func calculate_consumption(base_consumption: float, throttle: float, speed: float, route_factor: float) -> float:
	var speed_penalty := 1.0 + clamp(speed / 35.0, 0.0, 1.5)
	return base_consumption + throttle * max(speed, 1.0) * 0.006 * speed_penalty * route_factor
