class_name Passenger
extends Node3D

@export var passenger_data: PassengerData

var state_machine := PassengerStateMachine.new()
var fade_amount: float = 0.0
var fading_to_fog: bool = false

@onready var body: MeshInstance3D = get_node_or_null("Body") as MeshInstance3D


func _process(delta: float) -> void:
	if not fading_to_fog:
		return

	fade_amount = min(1.0, fade_amount + delta * 0.55)
	_set_fade_shader_amount(fade_amount)
	if fade_amount >= 1.0:
		visible = false
		set_process(false)


func _ready() -> void:
	if body != null and body.material_override is ShaderMaterial:
		body.material_override = body.material_override.duplicate()


func board() -> void:
	state_machine.set_state(PassengerStateMachine.State.BOARDING)
	visible = false


func leave_in_fog() -> void:
	state_machine.set_state(PassengerStateMachine.State.LEFT_IN_FOG)
	fading_to_fog = true
	set_process(true)


func reset_to_waiting() -> void:
	state_machine.set_state(PassengerStateMachine.State.WAITING)
	fade_amount = 0.0
	fading_to_fog = false
	visible = true
	_set_fade_shader_amount(0.0)


func _set_fade_shader_amount(value: float) -> void:
	if body == null:
		return
	var material := body.material_override as ShaderMaterial
	if material != null:
		material.set_shader_parameter("fade_amount", value)
