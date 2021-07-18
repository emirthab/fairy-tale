extends KinematicBody

var velocity = Vector3()
var direction = Vector3()
var speed = 5
var acceleration = 5
var air_acceleration : float = 5
var mouse_sensivity = 0.1
var jump_power = 18
var max_terminal_velocity : float = 54
var gravity : float = 0.98
var y_velocity : float
var friction : float = 0.5

onready var pivot = $Pivot
onready var raycast = $Pivot/Camera/RayCast

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	var just_pressed = event.is_pressed() and not event.is_echo()

	if Input.is_key_pressed(KEY_ESCAPE) and just_pressed:
		if Input.get_mouse_mode() == 0:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x * mouse_sensivity))
		pivot.rotate_x(deg2rad(-event.relative.y * mouse_sensivity))
		pivot.rotation.x = clamp(pivot.rotation.x,deg2rad(-90),deg2rad(90))

	if event is InputEventMouseButton:
		if event.button_index == 2:
			if $Pivot/Camera.fov == 70:
				$Pivot/Camera.fov = 50
				$Pivot/Camera/TextureRect.show()
				mouse_sensivity = 0.06
			else:
				$Pivot/Camera.fov = 70
				$Pivot/Camera/TextureRect.hide()
				mouse_sensivity = 0.1

func _physics_process(delta):
	handle_movement(delta)


func handle_movement(delta):
	print(velocity)
	if velocity != Vector3(0,-0.01,0) && !Input.is_action_pressed("speed_up") && is_on_floor():
		$character/AnimationPlayer.play("walk")

	elif Input.is_action_pressed("speed_up") && velocity != Vector3(0,0,0) && is_on_floor():
		$character/AnimationPlayer.play("run")

	elif is_on_floor():
		$character/AnimationPlayer.play("idle")
	
	if Input.is_action_pressed("speed_up"):	
		speed = 15
	else:
		speed = 5
		
	direction = Vector3()
	if Input.is_action_pressed("move_forward"):
		direction -= transform.basis.z
	
	elif Input.is_action_pressed("move_backward"):
		direction += transform.basis.z
	
	if Input.is_action_pressed("move_left"):
		direction -= transform.basis.x
	
	elif Input.is_action_pressed("move_right"):
		direction += transform.basis.x
	
	var accel = acceleration if is_on_floor() else air_acceleration
	velocity = velocity.linear_interpolate(direction * speed, accel * delta)
	direction = direction.normalized()
	velocity = direction * speed

	if is_on_floor():
		y_velocity = -0.01
	else:
		y_velocity = clamp(y_velocity - gravity, -max_terminal_velocity, max_terminal_velocity)

	if Input.is_action_just_pressed("move_jump") and is_on_floor():
		$character/AnimationPlayer.play("jump")
		y_velocity = jump_power

	velocity.y = y_velocity
	move_and_slide(velocity,Vector3.UP)
