class_name MainGame
extends Node3D

@export var start_openxr_if_available: bool = true


func _ready() -> void:
	if start_openxr_if_available:
		_try_start_openxr()


func _try_start_openxr() -> void:
	var xr_interface := XRServer.find_interface("OpenXR")
	if xr_interface != null and xr_interface.is_initialized():
		get_viewport().use_xr = true
