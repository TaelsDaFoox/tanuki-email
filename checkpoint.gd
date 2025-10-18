extends Node3D
@onready var mesh = $Cube
func _physics_process(delta: float) -> void:
	mesh.rotation.y+=delta*10
