class_name SteamPlumeController
extends GPUParticles3D

@export var plume_side_bias: float = 0.0
@export var is_side_vent: bool = false
@export var max_reference_speed: float = 35.0
@export var vertical_lift: float = 1.45
@export var forward_push: float = -0.35
@export var cabin_guard_front_z: float = -1.25
@export var minimum_safe_forward_push: float = -0.22

var train: TrainController
var particle_material: ParticleProcessMaterial
var base_position: Vector3
var current_side_drift: float = 0.0
var guard_was_triggered: bool = false


func _ready() -> void:
	base_position = position
	train = _find_train_controller()

	if process_material is ParticleProcessMaterial:
		particle_material = (process_material as ParticleProcessMaterial).duplicate()
		process_material = particle_material

	# Keep steam in train-local space. World-space particles trail behind the
	# moving locomotive and can drift straight into the cabin view.
	local_coords = true
	visibility_aabb = AABB(Vector3(-10.0, -2.0, -10.0), Vector3(20.0, 12.0, 20.0))
	_enforce_cabin_guard(true)


func _process(delta: float) -> void:
	if particle_material == null:
		return

	var speed: float = 0.0
	var throttle: float = 0.0
	var curve_bias: float = 0.0
	if train != null:
		speed = train.current_speed
		throttle = train.acceleration_input
		curve_bias = _get_curve_bias(train.distance_along_path)

	var speed_ratio: float = clampf(speed / max(max_reference_speed, 0.1), 0.0, 1.0)
	var target_side_drift: float = curve_bias * speed_ratio
	if is_side_vent:
		target_side_drift += plume_side_bias * (0.65 + speed_ratio * 0.8)
	else:
		target_side_drift += plume_side_bias * speed_ratio * 0.45

	current_side_drift = lerpf(current_side_drift, target_side_drift, delta * 3.0)

	if is_side_vent:
		_update_side_vent(speed_ratio, throttle)
	else:
		_update_main_chimney(speed_ratio, throttle)

	_enforce_cabin_guard(false)


func _update_main_chimney(speed_ratio: float, throttle: float) -> void:
	position = base_position + Vector3(current_side_drift * 0.18, speed_ratio * 0.45, -speed_ratio * 0.35)
	amount = roundi(lerpf(18.0, 34.0, max(speed_ratio, throttle)))
	lifetime = lerpf(1.85, 1.05, speed_ratio)

	particle_material.direction = Vector3(
		current_side_drift * 0.65,
		vertical_lift + speed_ratio * 0.85,
		min(forward_push - speed_ratio * 0.45, minimum_safe_forward_push)
	).normalized()
	particle_material.spread = lerpf(10.0, 24.0, speed_ratio)
	particle_material.initial_velocity_min = lerpf(1.5, 3.6, speed_ratio)
	particle_material.initial_velocity_max = lerpf(2.5, 5.3, speed_ratio)
	particle_material.scale_min = lerpf(0.28, 0.45, throttle)
	particle_material.scale_max = lerpf(0.75, 1.05, throttle)
	particle_material.gravity = Vector3(current_side_drift * 0.65, 0.65 + speed_ratio * 0.55, -0.34)


func _update_side_vent(speed_ratio: float, throttle: float) -> void:
	position = base_position + Vector3(plume_side_bias * speed_ratio * 0.18, speed_ratio * 0.15, 0.0)
	amount = roundi(lerpf(4.0, 16.0, max(speed_ratio, throttle)))
	lifetime = lerpf(0.95, 0.65, speed_ratio)

	particle_material.direction = Vector3(
		current_side_drift,
		0.95 + speed_ratio * 0.35,
		-0.28
	).normalized()
	particle_material.spread = 16.0
	particle_material.initial_velocity_min = lerpf(0.75, 1.6, speed_ratio)
	particle_material.initial_velocity_max = lerpf(1.4, 2.7, speed_ratio)
	particle_material.scale_min = 0.18
	particle_material.scale_max = 0.48
	particle_material.gravity = Vector3(current_side_drift * 0.5, 0.35, -0.18)


func _enforce_cabin_guard(force_restart: bool) -> void:
	if particle_material == null:
		return

	var guard_triggered := false
	if position.z > cabin_guard_front_z:
		position.z = cabin_guard_front_z - (0.25 if is_side_vent else 1.1)
		guard_triggered = true

	if particle_material.direction.z > minimum_safe_forward_push:
		particle_material.direction.z = minimum_safe_forward_push
		particle_material.direction = particle_material.direction.normalized()
		guard_triggered = true

	if particle_material.gravity.z > -0.05:
		particle_material.gravity.z = -0.18
		guard_triggered = true

	if guard_triggered and (force_restart or not guard_was_triggered):
		restart()
	guard_was_triggered = guard_triggered


func _get_curve_bias(distance: float) -> float:
	if train == null:
		return 0.0

	var local_progress: float = fposmod(distance, train.curve_check_period)
	var in_curve: bool = local_progress >= train.curve_check_start and local_progress <= train.curve_check_end
	if not in_curve:
		return sin(distance * 0.015) * 0.18

	# Alternates left/right by curve so the plume visibly peels toward side windows.
	return sign(sin(distance * 0.032) + 0.01)


func _find_train_controller() -> TrainController:
	var node: Node = self
	while node != null:
		if node is TrainController:
			return node as TrainController
		node = node.get_parent()
	return null
