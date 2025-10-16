extends CharacterBody3D
@export var topSpeed := 10.0
@export var jumpStrength := 10.0
@export var gravityForce := 10.0
@export var accel := 10.0
@export var dashSpeed := 30.0
var momentum := 0.0
var move_angle : = 0.0
@onready var camPivot = $SpringArm3D
@export var mouseSensitivity := 0.005
@onready var playermodel = $PlayerModel
var astralprojecting = false
var dashesleft := 2
#var dashing := false
@export var maxdashes :=2
var currentdashtype :=0
var input_dir = Vector2.ZERO

func _physics_process(delta: float) -> void:
	input_dir = Input.get_vector("left","right","forward","backward",0.5)
	if input_dir:
		#move_angle = lerp_angle(move_angle,input_dir.angle()+camPivot.rotation.y,delta*10)
		move_angle = input_dir.angle()-camPivot.rotation.y
	momentum = move_toward(momentum, input_dir.length()*topSpeed,accel*delta)
	if astralprojecting:
		if currentdashtype==0:
			momentum=dashSpeed
			velocity.y=0
		else:
			momentum=0
			velocity.y=dashSpeed
	velocity.x=momentum*cos(move_angle)
	velocity.z=momentum*sin(move_angle)
	
	if is_on_floor():
		if velocity.y<0:
			velocity.y=0
		dashesleft=maxdashes
	else:
		if not astralprojecting:
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
	if event.is_action_pressed("jump"):
		if is_on_floor():
			velocity.y=jumpStrength
		else:
			if dashesleft>0 and not astralprojecting:
				dashesleft-=1
				if input_dir:
					currentdashtype=0
				else:
					currentdashtype=1
				remove_child(playermodel)
				get_parent().add_child(playermodel)
				playermodel.position = position
				astralprojecting=true
				await get_tree().create_timer(0.25).timeout
				get_parent().remove_child(playermodel)
				add_child(playermodel)
				playermodel.position=Vector3.ZERO
				momentum=topSpeed
				if currentdashtype==1:
					velocity.y=dashSpeed/3
				astralprojecting=false
