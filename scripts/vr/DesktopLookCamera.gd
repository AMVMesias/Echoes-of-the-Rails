class_name DesktopLookCamera
extends Camera3D

@export var enabled_for_desktop: bool = true
@export var mouse_sensitivity: float = 0.003
@export var min_pitch_degrees: float = -58.0
@export var max_pitch_degrees: float = 32.0
@export var yaw_limit_degrees: float = 62.0
@export var bob_strength: float = 0.016
@export var max_bob_speed: float = 35.0
@export var cabin_move_speed: float = 1.8
@export var cabin_fast_multiplier: float = 2.2
@export var min_local_position: Vector3 = Vector3(-2.1, 1.0, -2.15)
@export var max_local_position: Vector3 = Vector3(2.1, 2.65, 1.8)
@export var default_local_position: Vector3 = Vector3(0.0, 2.15, 1.05)

var yaw: float = 0.0
var pitch: float = deg_to_rad(-8.0)
var current_speed: float = 0.0
var base_v_offset: float = 0.0


func _ready() -> void:
	if enabled_for_desktop:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	default_local_position = position
	base_v_offset = v_offset
	pitch = rotation.x
	yaw = rotation.y
	if not EventBus.train_speed_changed.is_connected(_on_train_speed_changed):
		EventBus.train_speed_changed.connect(_on_train_speed_changed)


func _input(event: InputEvent) -> void:
	if not enabled_for_desktop:
		return

	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		var motion := event as InputEventMouseMotion
		yaw -= motion.relative.x * mouse_sensitivity
		pitch -= motion.relative.y * mouse_sensitivity
		yaw = clamp(yaw, -deg_to_rad(yaw_limit_degrees), deg_to_rad(yaw_limit_degrees))
		pitch = clamp(pitch, deg_to_rad(min_pitch_degrees), deg_to_rad(max_pitch_degrees))
		rotation.y = yaw
		rotation.x = pitch


func _process(_delta: float) -> void:
	_update_cabin_movement(_delta)
	var speed_ratio: float = clampf(current_speed / max(max_bob_speed, 0.1), 0.0, 1.0)
	var time: float = float(Time.get_ticks_msec()) / 1000.0
	v_offset = base_v_offset + sin(time * 18.0) * bob_strength * speed_ratio


func _on_train_speed_changed(speed: float) -> void:
	current_speed = speed


func _update_cabin_movement(delta: float) -> void:
	if not enabled_for_desktop:
		return

	var move := Vector3.ZERO
	var forward := Vector3(-sin(yaw), 0.0, -cos(yaw))
	var right := Vector3(cos(yaw), 0.0, -sin(yaw))

	if Input.is_physical_key_pressed(KEY_I):
		move += forward
	if Input.is_physical_key_pressed(KEY_K):
		move -= forward
	if Input.is_physical_key_pressed(KEY_L):
		move += right
	if Input.is_physical_key_pressed(KEY_J):
		move -= right
	if Input.is_physical_key_pressed(KEY_E):
		move.y += 1.0
	if Input.is_physical_key_pressed(KEY_Q):
		move.y -= 1.0

	if Input.is_physical_key_pressed(KEY_C):
		position = default_local_position
		return

	if move.length_squared() <= 0.0:
		return

	var speed := cabin_move_speed
	if Input.is_physical_key_pressed(KEY_SHIFT):
		speed *= cabin_fast_multiplier

	position += move.normalized() * speed * delta
	position.x = clampf(position.x, min_local_position.x, max_local_position.x)
	position.y = clampf(position.y, min_local_position.y, max_local_position.y)
	position.z = clampf(position.z, min_local_position.z, max_local_position.z)
