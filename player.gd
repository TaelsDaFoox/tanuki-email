extends CharacterBody3D
@export var topSpeed := 10.0
@export var jumpStrength := 10.0
@export var gravityForce := 10.0
@export var accel := 10.0
var momentum := 0.0
var move_angle : = 0.0
@onready var camPivot = $SpringArm3D
@export var mouseSensitivity := 0.005

func _physics_process(delta: float) -> void:
	var input_dir = Input.get_vector("left","right","forward","backward",0.5)
	if input_dir:
		#move_angle = lerp_angle(move_angle,input_dir.angle()+camPivot.rotation.y,delta*10)
		move_angle = input_dir.angle()-camPivot.rotation.y
	momentum = move_toward(momentum, input_dir.length()*topSpeed,accel*delta)
	velocity.x=momentum*cos(move_angle)
	velocity.z=momentum*sin(move_angle)
	
	if is_on_floor():
		if velocity.y<0:
			velocity.y=0
	else:
		velocity.y-=gravityForce*delta
	
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		camPivot.rotation.y-=event.relative.x*mouseSensitivity
		camPivot.rotation.x-=event.relative.y*mouseSensitivity
	if event.is_action_pressed("lock mouse"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action_pressed("unlock mouse"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event.is_action_pressed("jump") and is_on_floor():
		velocity.y=jumpStrength
