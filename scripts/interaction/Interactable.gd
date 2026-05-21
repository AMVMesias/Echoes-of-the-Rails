class_name Interactable
extends Area3D

@export var hover_scale: float = 1.04

var _base_scale: Vector3 = Vector3.ONE
var _hovered: bool = false


func _ready() -> void:
	_base_scale = scale


func on_hover_enter() -> void:
	_hovered = true
	scale = _base_scale * hover_scale


func on_hover_exit() -> void:
	_hovered = false
	scale = _base_scale


func interact() -> void:
	pass
