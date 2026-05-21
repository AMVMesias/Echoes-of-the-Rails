class_name LaserPointer
extends Node3D

@export var raycast_path: NodePath = NodePath("RayCast3D")
@export var pointer_mesh_path: NodePath = NodePath("LaserMesh")
@export var trigger_action: StringName = &"trigger_click"

var hovered: Interactable

@onready var raycast: RayCast3D = get_node_or_null(raycast_path) as RayCast3D
@onready var pointer_mesh: MeshInstance3D = get_node_or_null(pointer_mesh_path) as MeshInstance3D


func _ready() -> void:
	var controller := get_parent()
	if controller != null and controller.has_signal("button_pressed"):
		controller.button_pressed.connect(_on_controller_button_pressed)


func _process(_delta: float) -> void:
	_update_hover()
	if Input.is_key_pressed(KEY_SPACE):
		interact_with_hovered()


func interact_with_hovered() -> void:
	if hovered != null:
		hovered.interact()


func _update_hover() -> void:
	if raycast == null:
		return

	raycast.force_raycast_update()
	var next_hovered: Interactable = null
	if raycast.is_colliding():
		next_hovered = raycast.get_collider() as Interactable

	if next_hovered == hovered:
		return

	if hovered != null:
		hovered.on_hover_exit()
	hovered = next_hovered
	if hovered != null:
		hovered.on_hover_enter()


func _on_controller_button_pressed(button_name: StringName) -> void:
	if button_name == &"trigger_click" or button_name == trigger_action:
		interact_with_hovered()
