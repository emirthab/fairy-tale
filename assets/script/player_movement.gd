extends KinematicBody

var velocity = Vector3()
var direction = Vector3()
export var speed_up = 8
export var normal_speed = 4
var speed = normal_speed
var acceleration = 5
var air_acceleration : float = 5
export var mouse_sensivity = 0.004
export var jump_power = 18
var max_terminal_velocity : float = 54
var gravity : float = 0.98
var y_velocity : float

onready var char_pivot = $character_pivot
onready var puppet_pivot = $PuppetPivot
onready var pivot = $Pivot

onready var character_sword = $character_sword
onready var character = character_sword

onready var animplayer = character.get_node("AnimationPlayer")

func _input(event):

	var just_pressed = event.is_pressed() and not event.is_echo()

	if Input.is_key_pressed(KEY_ESCAPE) and just_pressed and $ui.game:
		if Input.get_mouse_mode() == 0:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	if event is InputEventMouseMotion && Input.get_mouse_mode() != 0 and $ui.game:
		var resultant = sqrt((event.relative.x * event.relative.x )+ (event.relative.y * event.relative.y ))
		var rot = Vector3(-event.relative.y,-event.relative.x,0).normalized()
		puppet_pivot.rotate_object_local(rot , resultant * mouse_sensivity)
		puppet_pivot.rotation.z = clamp(puppet_pivot.rotation.z,deg2rad(-0),deg2rad(0))
		puppet_pivot.rotation.x = clamp(puppet_pivot.rotation.x,deg2rad(-30),deg2rad(30))

func _physics_process(delta):
	if $ui.game:
		#pivot.rotation.z = lerp_angle(pivot.rotation.z, puppet_pivot.rotation.z ,delta * 10)
		pivot.rotation.x = lerp_angle(pivot.rotation.x, puppet_pivot.rotation.x ,delta * 10)
		pivot.rotation.y = lerp_angle(pivot.rotation.y, puppet_pivot.rotation.y ,delta * 10)
		#pivot.rotation = pivot.rotation.linear_interpolate(puppet_pivot.rotation,delta * 10)
		pivot.global_transform.origin = pivot.global_transform.origin.linear_interpolate(character.get_node("RemotePivot").global_transform.origin,delta *2)
	
	elif $ui.camera_interpolation:
		pivot.rotation.x = lerp_angle(pivot.rotation.x, puppet_pivot.rotation.x ,delta * 2)
		pivot.rotation.y = lerp_angle(pivot.rotation.y, puppet_pivot.rotation.y ,delta * 2)
		pivot.global_transform.origin = pivot.global_transform.origin.linear_interpolate(character.get_node("RemotePivot").global_transform.origin,delta *1)
	
	if velocity != Vector3(0,-0.01,0) && !Input.is_action_pressed("speed_up") && is_on_floor() && !$combat.attacking() && !$combat.hurting():
		animplayer.play("walk")

	elif Input.is_action_pressed("speed_up") && velocity != Vector3(0,-0.01,0) && is_on_floor() && !$combat.attacking() && !$combat.hurting():
		animplayer.play("run")

	elif is_on_floor() && !$combat.attacking() && !$combat.hurting():
		animplayer.play("idle")
	
	if Input.is_action_pressed("speed_up"):
		speed = speed_up
	else:
		speed = normal_speed

	direction = Vector3()
	if !$combat.attacking() && !$combat.hurting():
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

	if Input.is_action_just_pressed("move_jump") and is_on_floor() && !$combat.hurting() && !$combat.attacking() and $ui.game:
		animplayer.play("jump")
		y_velocity = jump_power
	
	if $ui.game:
		velocity = velocity.linear_interpolate(direction * speed, acceleration * delta)
		direction = direction.normalized()
		velocity = direction * speed
	velocity.y = y_velocity

	if !Death.dead:
		move_and_slide(velocity,Vector3.UP)
		
	if direction != Vector3(0,0,0) && $combat.current_attack == 0 and $ui.game:
		character.rotation.y = lerp_angle(character.rotation.y, atan2(direction.x,direction.z),delta * 5)
		#$combat.target_pivot.rotation.y = character.rotation.y
		#$character.look_at(global_transform.origin - velocity, Vector3.UP
		var look = (global_transform.origin - character.transform.basis.z)
		$combat.target_pivot.look_at(look,Vector3.UP)
	elif direction != Vector3(0,0,0):
		var look = Vector3(global_transform.origin.x - direction.x,0,global_transform.origin.z - direction.z)
		$combat.target_pivot.look_at(look,Vector3.UP)
	else:
		var look = (global_transform.origin - character.transform.basis.z)
		$combat.target_pivot.look_at(look,Vector3.UP)
