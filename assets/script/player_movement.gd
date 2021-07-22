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

onready var target = $targetpivot/target
onready var target_pivot = $targetpivot
export var attack_moving = false
var attackers = []
var target_dir
var current_attack = 0

onready var char_pivot = $character_pivot
onready var puppet_pivot = $PuppetPivot
onready var pivot = $Pivot

onready var character = $character_sword
onready var raycast = $Pivot/Camera/RayCast
onready var animplayer = character.get_node("AnimationPlayer")

func _ready():
	$attack_area.connect("body_entered",self,"attack_area_entered")
	$attack_area.connect("body_exited",self,"attack_area_exited")
	animplayer.connect("animation_finished",self,"finish_attack")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if Input.is_action_pressed("attack"):
		if current_attack == 0:
			current_attack = 1
			animplayer.play("attack")

	var just_pressed = event.is_pressed() and not event.is_echo()

	if Input.is_key_pressed(KEY_ESCAPE) and just_pressed:
		if Input.get_mouse_mode() == 0:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	if event is InputEventMouseMotion && Input.get_mouse_mode() != 0:
		var resultant = sqrt((event.relative.x * event.relative.x )+ (event.relative.y * event.relative.y ))
		var rot = Vector3(-event.relative.y,-event.relative.x,0).normalized()
		puppet_pivot.rotate_object_local(rot , resultant * mouse_sensivity)
		puppet_pivot.rotation.z = clamp(puppet_pivot.rotation.z,deg2rad(-0),deg2rad(0))
		puppet_pivot.rotation.x = clamp(puppet_pivot.rotation.x,deg2rad(-30),deg2rad(30))

func _physics_process(delta):
	auto_focus(delta)
	handle_movement(delta)


func handle_movement(delta):

	#pivot.rotation.z = lerp_angle(pivot.rotation.z, puppet_pivot.rotation.z ,delta * 10)
	pivot.rotation.x = lerp_angle(pivot.rotation.x, puppet_pivot.rotation.x ,delta * 10)
	pivot.rotation.y = lerp_angle(pivot.rotation.y, puppet_pivot.rotation.y ,delta * 10)
	#pivot.rotation = pivot.rotation.linear_interpolate(puppet_pivot.rotation,delta * 10)
	pivot.global_transform.origin = pivot.global_transform.origin.linear_interpolate(character.get_node("RemotePivot").global_transform.origin,delta *2)
	
	if velocity != Vector3(0,-0.01,0) && !Input.is_action_pressed("speed_up") && is_on_floor() && current_attack == 0:
		animplayer.play("walk")

	elif Input.is_action_pressed("speed_up") && velocity != Vector3(0,-0.01,0) && is_on_floor() && current_attack == 0:
		animplayer.play("run")

	elif is_on_floor() && current_attack == 0:
		animplayer.play("idle")
	
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
		animplayer.play("jump")
		y_velocity = jump_power

	velocity = velocity.linear_interpolate(direction * speed, acceleration * delta)
	direction = direction.normalized()
	velocity = direction * speed
	velocity.y = y_velocity
	if current_attack == 0:
		move_and_slide(velocity,Vector3.UP)
	if attack_moving:
		print("moving")
		var attack_dir = target.global_transform.origin - character.global_transform.origin
		attack_dir = attack_dir.normalized() * delta * 10
		attack_dir.y = -0.01
		move_and_collide(attack_dir)
	
	if direction != Vector3(0,0,0) && current_attack == 0:
		character.rotation.y = lerp_angle(character.rotation.y, atan2(direction.x,direction.z),delta * 5)
		target_pivot.rotation.y = character.rotation.y
		#$character.look_at(global_transform.origin - velocity, Vector3.UP
	elif direction != Vector3(0,0,0):
		var look = Vector3(global_transform.origin.x - direction.x,0,global_transform.origin.z - direction.z)
		target_pivot.look_at(look,Vector3.UP)
	else:
		print("aaadasd")
		var look = (global_transform.origin - character.transform.basis.z)
		target_pivot.look_at(look,Vector3.UP)

func finish_attack(anim_name):
	if anim_name == "attack":
		if Input.is_action_pressed("attack"):
			current_attack = 2
			animplayer.play("slash_1")
		else:
			current_attack = 0
	elif anim_name == "slash_1":
		if Input.is_action_pressed("attack"):
			current_attack = 2
			animplayer.play("slash_2")
		else:
			current_attack = 0
	elif anim_name == "slash_2":
		current_attack = 0

func attack_area_entered(body):
	if body.name == "enemy":
		attackers.append(body)

func attack_area_exited(body):
	if body.name == "enemy":
		attackers.erase(body)

func auto_focus(delta):

	if attackers.size() > 0:
		var oldenemy
		for i in range(0, attackers.size()):
			var newenemy = attackers[i]
			var enemydir = newenemy.global_transform.origin - global_transform.origin
			enemydir = enemydir.normalized()
			if i != 0:
				var new_gap = sqrt((newenemy.global_transform.origin.x - target.global_transform.origin.x)*(newenemy.global_transform.origin.x - target.global_transform.origin.x) + (newenemy.global_transform.origin.z - target.global_transform.origin.z)*(newenemy.global_transform.origin.z - target.global_transform.origin.z))
				var old_gap = sqrt((oldenemy.global_transform.origin.x - target.global_transform.origin.x)*(oldenemy.global_transform.origin.x - target.global_transform.origin.x) + (oldenemy.global_transform.origin.z - target.global_transform.origin.z)*(oldenemy.global_transform.origin.z - target.global_transform.origin.z))
				if new_gap < old_gap:
					oldenemy = newenemy
					target_dir = enemydir
			else:
				oldenemy = newenemy
				target_dir = enemydir

	if current_attack != 0 && attackers.size() > 0:
		character.rotation.y = lerp_angle(character.rotation.y, atan2(target_dir.x,target_dir.z),delta * 5)
	elif current_attack != 0:
		print("aaaa")
		var dir = target.global_transform.origin - character.global_transform.origin
		character.rotation.y = lerp_angle(character.rotation.y, atan2(dir.x,dir.z),delta * 5)

