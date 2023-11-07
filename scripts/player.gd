extends CharacterBody3D

#Import nodes
@onready var head = $head
@onready var standing_collision_shape = $standing_collision_shape
@onready var crouching_collision_shape = $crouching_collision_shape
@onready var ray_cast_3d = $RayCast3D

#Declare player speeds
var CURRENT_SPEED = 5.0
const JUMP_VELOCITY = 4.5

const WALKING_SPEED = 5.0
const SPRINTING_SPEED = 8.0
const CROUCHING_SPEED = 3.0

var LERP_SPEED = 10.0

#Declare mouse units
var direction = Vector3.ZERO
const MOUSE_SENSITIVITY =  0.4

#Declare crouch units
var CROUCHING_DEPTH = -0.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	#Remove mouse within window
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	#Check for mouse movement
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * MOUSE_SENSITIVITY))
		head.rotate_x(deg_to_rad(-event.relative.y * MOUSE_SENSITIVITY))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))

func _physics_process(delta):
	#Check if crouch activated
	if Input.is_action_pressed("crouch"):
		#Set crouch settings
		CURRENT_SPEED = CROUCHING_SPEED
		head.position.y = lerp(head.position.y, 1.8 + CROUCHING_DEPTH, delta)
		standing_collision_shape.disabled = true
		crouching_collision_shape.disabled = false
	#Disallow uncrouch if collision detected above	
	elif !ray_cast_3d.is_colliding():
		#Set uncrouch settings
		standing_collision_shape.disabled = false
		crouching_collision_shape.disabled = true
		head.position.y = lerp(head.position.y, 1.8, delta)
		#Check if sprint activated
		if Input.is_action_pressed("sprint"):
			CURRENT_SPEED = SPRINTING_SPEED
		else:
			CURRENT_SPEED = WALKING_SPEED
	
	# Add gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * LERP_SPEED)
	if direction:
		velocity.x = direction.x * CURRENT_SPEED
		velocity.z = direction.z * CURRENT_SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, CURRENT_SPEED)
		velocity.z = move_toward(velocity.z, 0, CURRENT_SPEED)

	move_and_slide()
