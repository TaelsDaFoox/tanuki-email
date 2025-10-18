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
@onready var animator = $PlayerModel/AnimationPlayer
var astralprojecting = false
var dashesleft := 2
#var dashing := false
@export var maxdashes :=2
var currentdashtype :=0
var input_dir = Vector2.ZERO

func _physics_process(delta: float) -> void:
	if animator:
		if velocity.length()>0.1:
			animator.play("Walk",0.2,velocity.length()/8)
		else:
			animator.play("Idle",0.2,1)
	var lerpdist = 5
	if not astralprojecting:
		input_dir = Input.get_vector("left","right","forward","backward",0.5)
		playermodel.scale.y = move_toward(playermodel.scale.y,0.6,delta*lerpdist)
		playermodel.scale.x = move_toward(playermodel.scale.x,0.6,delta*lerpdist)
		playermodel.scale.z = move_toward(playermodel.scale.z,0.6,delta*lerpdist)
	else:
		playermodel.scale.y = move_toward(playermodel.scale.y,1.2,delta*lerpdist)
		playermodel.scale.x = move_toward(playermodel.scale.x,0,delta*lerpdist)
		playermodel.scale.z = move_toward(playermodel.scale.z,0,delta*lerpdist)
	if input_dir:
		#move_angle = lerp_angle(move_angle,input_dir.angle()+camPivot.rotation.y,delta*10)
		move_angle = input_dir.angle()-camPivot.rotation.y
		playermodel.rotation.y=lerp_angle(playermodel.rotation.y,-move_angle+PI/2,delta*20)
	momentum = move_toward(momentum, input_dir.length()*topSpeed,accel*delta)
	if astralprojecting:
		if currentdashtype==0:
			momentum=dashSpeed
			velocity.y=0
		else:
			momentum=0
			velocity.y=dashSpeed/2
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
	
	if position.y<-25:
		position=Vector3(0,1,0)

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
				if currentdashtype==1:
					await get_tree().create_timer(0.2).timeout
				else:
					await get_tree().create_timer(0.25).timeout
				get_parent().remove_child(playermodel)
				add_child(playermodel)
				playermodel.position=Vector3(0,-0.3,0)
				momentum=topSpeed
				if currentdashtype==1:
					velocity.y=dashSpeed/3
					momentum=0
				else:
					velocity.y=10
				astralprojecting=false
