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

var attackers = []
var target_dir
var current_attack = 0

#debug
onready var textedit = get_node("../TextEdit")

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
	if Input.is_action_pressed("move_forward") && current_attack == 0:
		direction -= pivot.transform.basis.z
		
	elif Input.is_action_pressed("move_backward") && current_attack == 0:
		direction += pivot.transform.basis.z
		
	if Input.is_action_pressed("move_left") && current_attack == 0:
		direction -= pivot.transform.basis.x
		
	elif Input.is_action_pressed("move_right") && current_attack == 0:
		direction += pivot.transform.basis.x
	
	var accel = acceleration if is_on_floor() else air_acceleration

	if is_on_floor():
		y_velocity = -0.01
	else:
		y_velocity = clamp(y_velocity - gravity, -max_terminal_velocity, max_terminal_velocity)

	if Input.is_action_just_pressed("move_jump") and is_on_floor() && current_attack == 0:
		animplayer.play("jump")
		y_velocity = jump_power

	velocity = velocity.linear_interpolate(direction * speed, acceleration * delta)
	direction = direction.normalized()
	velocity = direction * speed
	velocity.y = y_velocity
	move_and_slide(velocity,Vector3.UP)
	
	#if current_attack == 1:
		#var dir = character.transform.basis.z * delta * 15
		#character.rotation.y = lerp_angle(character.rotation.y, atan2(dir.x,dir.z),delta * 5)
	if direction != Vector3(0,0,0):
		character.rotation.y = lerp_angle(character.rotation.y, atan2(direction.x,direction.z),delta * 5)
		#$character.look_at(global_transform.origin - velocity, Vector3(0, 1, 0))
	
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
		print("deneme")
		attackers.append(body)

func attack_area_exited(body):
	if body.name == "enemy":
		print("denem2e")
		attackers.erase(body)

func auto_focus(delta):
	var playerrot = fmod(character.rotation.y,2 * PI)
	if playerrot < 0:
		playerrot += 2 * PI
	
	if attackers.size() == 4:
		var a = atan2((attackers[0].global_transform.origin - global_transform.origin).normalized().x,(attackers[0].global_transform.origin - global_transform.origin).normalized().z)
		var b = atan2((attackers[1].global_transform.origin - global_transform.origin).normalized().x,(attackers[1].global_transform.origin - global_transform.origin).normalized().z)
		var c = atan2((attackers[2].global_transform.origin - global_transform.origin).normalized().x,(attackers[2].global_transform.origin - global_transform.origin).normalized().z)
		var d = atan2((attackers[3].global_transform.origin - global_transform.origin).normalized().x,(attackers[3].global_transform.origin - global_transform.origin).normalized().z) 

		if a < 0:
			a += 2 * PI
		if b < 0:
			b += 2 * PI
		if c < 0:
			c += 2 * PI
		if d < 0:
			d += 2 * PI
		
		var line0 = str("player rot : ",playerrot)
		var line1 = str(attackers[0].get_parent().name," : ",a)
		var line2 = str(attackers[1].get_parent().name," : ",b)
		var line3 = str(attackers[2].get_parent().name," : ",c)
		var line4 = str(attackers[3].get_parent().name," : ",d)
		textedit.text = str(line0,"\n",line1,"\n",line2,"\n",line3,"\n",line4)

	if attackers.size() > 0:

		if attackers.size() > 1:
			for i in range(0, attackers.size()):
				var enemy = attackers[i]
				var enemydir = enemy.global_transform.origin - global_transform.origin
				enemydir = enemydir.normalized()
				if i != 0:
					var tar_atan = atan2(target_dir.x,target_dir.z)
					if tar_atan < 0:
						tar_atan += 2 * PI 
					var enem_atan = atan2(enemydir.x,enemydir.z)
					if enem_atan < 0:
						enem_atan += 2 * PI
					var old_gap = abs(tar_atan - playerrot)
					var new_gap = abs(enem_atan - playerrot)
					if new_gap < old_gap:
						target_dir = enemydir
				else:
					target_dir = enemydir

		if current_attack != 0 && attackers.size() > 0:
			character.rotation.y = lerp_angle(character.rotation.y, atan2(target_dir.x,target_dir.z),delta * 5)
	
