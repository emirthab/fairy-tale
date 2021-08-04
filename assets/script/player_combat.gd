extends Node

onready var movement = get_parent()

export var health = 100
export var hit_power_1 = 10
export var hit_power_2 = 20
export var hit_power_3 = 30
export var power_chance_rate = 65
export var next_attack_cooldown = 0.5

export var hurt_speed = 4.3
export var default_anim_speed = 1.5
export var attack_1_speed = 1.5
export var attack_2_speed = 1.5
export var attack_3_speed = 1.5

var attack_moving = false
var next_attack = false

var timer = Timer.new()

onready var target = $targetpivot/target
onready var target_pivot = $targetpivot

var death = false
var attackers = []
var dashers = []
var hitable = []
var target_dir
var current_attack = 0

onready var character = movement.get_node("character_sword")
onready var animplayer = character.get_node("AnimationPlayer")

onready var ui = get_node("../ui")

onready var sounds = get_node("../sounds")

onready var so1 = sounds.get_node("hit_1")
onready var so2 = sounds.get_node("hit_2")
onready var so3 = sounds.get_node("hit_3")
onready var so4 = sounds.get_node("hurt")

func _input(event):
	if Input.is_action_just_released("attack"):
		timer.start()

	if Input.is_action_pressed("attack") and ui.game:
		next_attack = true
		if current_attack == 0 && !hurting():
			if attackers.size() == 0 && dashers.size() > 0:
				current_attack = 3
				animplayer.playback_speed = attack_3_speed
				animplayer.play("slash_2")
			else:
				current_attack = 1
				animplayer.playback_speed = attack_1_speed
				animplayer.play("attack")

func _ready():
	timer.wait_time = next_attack_cooldown
	timer.connect("timeout",self,"nex_attack_timeout") 
	timer.one_shot = true
	add_child(timer)
	
	$attack_area.connect("body_entered",self,"attack_area_entered")
	$attack_area.connect("body_exited",self,"attack_area_exited")
	$dash_area.connect("body_entered",self,"dash_area_entered")
	$dash_area.connect("body_exited",self,"dash_area_exited")

	character.get_node("hit_area").connect("body_entered",self,"hit_area_entered")
	character.get_node("hit_area").connect("body_exited",self,"hit_area_exited")

	character.get_node("AnimationPlayer").connect("animation_finished",self,"finish_attack")

func _physics_process(delta):
	if animplayer.current_animation != "slash_2":
		attack_moving = false

	auto_focus(delta)

	if attack_moving:
		var attack_dir = target.global_transform.origin - character.global_transform.origin
		attack_dir = attack_dir.normalized() * delta * 10
		attack_dir.y = -0.01
		movement.move_and_collide(attack_dir)

func finish_attack(anim_name):
	if anim_name == "attack":
		if next_attack && !hurting():
			current_attack = 2
			animplayer.playback_speed = attack_1_speed
			animplayer.play("slash_1")
		else:
			current_attack = 0
			animplayer.playback_speed = default_anim_speed
	elif anim_name == "slash_1":
		if next_attack && !hurting():
			current_attack = 2
			animplayer.playback_speed = attack_3_speed
			animplayer.play("slash_2")
		else:
			current_attack = 0
			animplayer.playback_speed = default_anim_speed
	elif anim_name == "slash_2":
		next_attack = false
		current_attack = 0
		animplayer.playback_speed = default_anim_speed
	elif anim_name == "hurt":
		animplayer.playback_speed = default_anim_speed
		current_attack = 0

func target_dir_calc(array):
	var oldenemy = null
	for i in range(0, array.size()):
		var newenemy = array[i]
		var enemydir = newenemy.global_transform.origin - movement.global_transform.origin
		enemydir = enemydir.normalized()
		newenemy.get_node("lock").visible = false
		if i != 0:
			var n_tx = (newenemy.global_transform.origin.x - target.global_transform.origin.x)
			var n_tz = (newenemy.global_transform.origin.z - target.global_transform.origin.z)
			var new_gap = sqrt(n_tx * n_tx + n_tz * n_tz)
			
			var o_tx = (oldenemy.global_transform.origin.x - target.global_transform.origin.x)
			var o_tz = (oldenemy.global_transform.origin.z - target.global_transform.origin.z)
			var old_gap = sqrt(o_tx * o_tx + o_tz * o_tz)
			
			if new_gap < old_gap:
				oldenemy = newenemy
				target_dir = enemydir
		else:
			oldenemy = newenemy
			target_dir = enemydir
	if oldenemy:
		oldenemy.get_node("lock").visible = true

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
	animplayer.playback_speed = hurt_speed
	animplayer.play("hurt")
	if health <= 0:
		Death.death()

func nex_attack_timeout():
	if !Input.is_action_pressed("attack"):
		next_attack = false

func attacking() -> bool:
	if current_attack == 0:
		return false
	else:
		return true

func hurting() -> bool:
	if animplayer.current_animation == "hurt":
		return true
	else:
		return false

func attack_area_entered(body):
	if body.name == "enemy":
		attackers.append(body)

func attack_area_exited(body):
	if body.name == "enemy":
		attackers.erase(body)
		body.get_node("lock").visible = false
		
func dash_area_entered(body):
	if body.name == "enemy":
		dashers.append(body)

func dash_area_exited(body):
	if body.name == "enemy":
		dashers.erase(body)
		body.get_node("lock").visible = false

func hit_area_entered(body):
	if body.name == "enemy":
		hitable.append(body)

func hit_area_exited(body):
	if body.name == "enemy":
		hitable.erase(body)
		
func play_sound(sound):
	match sound:
		1:
			so1.play()
		2:
			so2.play()
		3:
			so3.play()
		4:
			so4.play()
