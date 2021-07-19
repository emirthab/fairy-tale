extends KinematicBody

var velocity = Vector3()
var direction = Vector3()
var speed = 5
var acceleration = 5
var air_acceleration : float = 5
var mouse_sensivity = 0.004
var jump_power = 18
var max_terminal_velocity : float = 54
var gravity : float = 0.98
var y_velocity : float

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

	if event is InputEventMouseMotion && Input.get_mouse_mode() != 0:
		var resultant = sqrt((event.relative.x * event.relative.x )+ (event.relative.y * event.relative.y ))
		var rot = Vector3(-event.relative.y,-event.relative.x,0).normalized()
		pivot.rotate_object_local(rot , resultant * mouse_sensivity)
		pivot.rotation.z = clamp(pivot.rotation.z,deg2rad(-0),deg2rad(0))
		pivot.rotation.x = clamp(pivot.rotation.x,deg2rad(-30),deg2rad(30))

func _physics_process(delta):
	handle_movement(delta)


func handle_movement(delta):	
	
	if velocity != Vector3(0,-0.01,0) && !Input.is_action_pressed("speed_up") && is_on_floor():
		$character/AnimationPlayer.play("walk")

	elif Input.is_action_pressed("speed_up") && velocity != Vector3(0,-0.01,0) && is_on_floor():
		$character/AnimationPlayer.play("run")

	elif is_on_floor():
		$character/AnimationPlayer.play("idle")
	
	if Input.is_action_pressed("speed_up"):	
		speed = 15
	else:
		speed = 5

	direction = Vector3()
	if Input.is_action_pressed("move_forward"):
		direction -= pivot.transform.basis.z
		
	elif Input.is_action_pressed("move_backward"):
		direction += pivot.transform.basis.z
		
	if Input.is_action_pressed("move_left"):
		direction -= pivot.transform.basis.x
		
	elif Input.is_action_pressed("move_right"):
		direction += pivot.transform.basis.x
	
	var accel = acceleration if is_on_floor() else air_acceleration

	if is_on_floor():
		y_velocity = -0.01
	else:
		y_velocity = clamp(y_velocity - gravity, -max_terminal_velocity, max_terminal_velocity)

	if Input.is_action_just_pressed("move_jump") and is_on_floor():
		$character/AnimationPlayer.play("jump")
		y_velocity = jump_power
	
	velocity = velocity.linear_interpolate(direction * speed, acceleration * delta)
	direction = direction.normalized()
	velocity = direction * speed
	velocity.y = y_velocity
	move_and_slide(velocity,Vector3.UP)
	
	if direction != Vector3(0,0,0):
		$character.rotation.y = lerp_angle($character.rotation.y, atan2(direction.x,direction.z),delta * 5)
		#$character.look_at(global_transform.origin - velocity, Vector3(0, 1, 0))
