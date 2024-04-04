extends CharacterBody3D


var speed
var default_move_speed = 5
var crouch_move_speed = 3
var crouch_speed = 20
var is_crouching = false

var default_height = 2
var crouch_height = 1.5

const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.03

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var head = $Head
@onready var camera = $Head/Camera
@onready var col = $CollisionShape3D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)

func _physics_process(delta):
	speed = default_move_speed
	
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if Input.is_action_just_pressed("crouch"):
		is_crouching = !is_crouching
	
	if is_crouching:
		col.shape.height -= crouch_speed * delta
		speed = crouch_move_speed
	else:
		col.shape.height += crouch_speed * delta
		speed = default_move_speed
	
	col.shape.height = clamp(col.shape.height, crouch_height, default_height)

	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
