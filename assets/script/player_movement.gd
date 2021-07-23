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

export var health = 300
export var hit_power_1 = 10
export var hit_power_2 = 20
export var hit_power_3 = 30
export var power_chance_rate = 65

onready var target = $targetpivot/target
onready var target_pivot = $targetpivot
export var attack_moving = false

var death = false
var attackers = []
var dashers = []
var hitable = []
var target_dir
var current_attack = 0

onready var char_pivot = $character_pivot
onready var puppet_pivot = $PuppetPivot
onready var pivot = $Pivot

onready var character_non_sword = $character
onready var character_sword = $character_sword
onready var character = character_sword

onready var raycast = $Pivot/Camera/RayCast
onready var animplayer = character.get_node("AnimationPlayer")

func _ready():
	$attack_area.connect("body_entered",self,"attack_area_entered")
	$attack_area.connect("body_exited",self,"attack_area_exited")
	$dash_area.connect("body_entered",self,"dash_area_entered")
	$dash_area.connect("body_exited",self,"dash_area_exited")

	character_sword.get_node("hit_area").connect("body_entered",self,"hit_area_entered")
	character_sword.get_node("hit_area").connect("body_exited",self,"hit_area_exited")

	character_sword.get_node("AnimationPlayer").connect("animation_finished",self,"finish_attack")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if Input.is_action_pressed("attack"):
		if current_attack == 0:
			if attackers.size() == 0 && dashers.size() > 0:
				current_attack = 3
				animplayer.play("slash_2")
			else:
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
	elif anim_name == "slash_2" || anim_name == "hurt":
		current_attack = 0
		animplayer.playback_speed = 1.5

func attack_area_entered(body):
	if body.name == "enemy":
		attackers.append(body)

func attack_area_exited(body):
	if body.name == "enemy":
		attackers.erase(body)
		
func dash_area_entered(body):
	if body.name == "enemy":
		dashers.append(body)

func dash_area_exited(body):
	if body.name == "enemy":
		dashers.erase(body)

func hit_area_entered(body):
	if body.name == "enemy":
		hitable.append(body)

func hit_area_exited(body):
	if body.name == "enemy":
		hitable.erase(body)

func auto_focus(delta):

	if attackers.size() > 0:
		target_dir_calc(attackers)

	elif dashers.size() > 0:
		target_dir_calc(dashers)

	if current_attack != 0 && (attackers.size() > 0 || dashers.size() > 0) && !death:
		character.rotation.y = lerp_angle(character.rotation.y, atan2(target_dir.x,target_dir.z),delta * 5)

	elif current_attack != 0 && !death:
		var dir = target.global_transform.origin - character.global_transform.origin
		character.rotation.y = lerp_angle(character.rotation.y, atan2(dir.x,dir.z),delta * 5)

func target_dir_calc(array):
	var oldenemy
	for i in range(0, array.size()):
		var newenemy = array[i]
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

func hit(hit_turn):

	if hitable.size() > 0:
		var _pow = 0

		if hit_turn == 1:
			_pow = CalcPower.get_power(hit_power_1,power_chance_rate)

		if hit_turn == 2:
			_pow = CalcPower.get_power(hit_power_2,power_chance_rate)

		if hit_turn == 3:
			_pow = CalcPower.get_power(hit_power_3,power_chance_rate)

		for enemy in hitable:
			enemy.get_parent().hurt(_pow)

func hurt(power):
	health -= power
	current_attack = -1
	animplayer.play("hurt")
	animplayer.playback_speed = 3.4
	if health <= 0:
		Death.death()
