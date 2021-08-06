extends Spatial

onready var player = get_node("../player")
var on_spawn_point = true

onready var animplayer = $enemy/model/AnimationPlayer
var chase = false
var walking_to_spawn = false
var player_attack_area = false
var direction = Vector3()
#gravity
var y_velocity : float
var velocity = Vector3() 
var max_terminal_velocity : float = 54
var gravity : float = 0.98
var acceleration = 5
var air_acceleration : float = 5

export var hit_power = 7
export var power_chance = 60
export var speed = 6
export var cooldown = 2
export var chase_delay = 1.6

var delta_ = 0

var shoot_timer = Timer.new()
var chase_delay_timer = Timer.new()

var healthbar = preload("res://assets/sprite/enemy_healthbar.tscn").instance()

export var health = 150

var timer := 0.0
var refresh_rate := 0.25

func _ready():
	Death.connect("death_signal",self,"on_player_death")
	if $enemy.scale.x != 1:
		healthbar.scale.x = 1 / $enemy.scale.x
	$enemy.add_child(healthbar)

	shoot_timer.wait_time = cooldown
	shoot_timer.connect("timeout",self,"shoot") 
	shoot_timer.one_shot = false
	add_child(shoot_timer)
	
	chase_delay_timer.wait_time = chase_delay
	chase_delay_timer.connect("timeout",self,"chase_delay_timeout") 
	chase_delay_timer.one_shot = true
	add_child(chase_delay_timer)

	animplayer.connect("animation_finished",self,"finish_anim")
	$spawnpoint.connect("body_entered",self,"spawnpoint_entered")
	$spawnpoint.connect("body_exited",self,"spawnpoint_exited")
	$enemy/look_area.connect("body_entered",self,"look_entered")
	$spawnarea.connect("body_exited",self,"spawn_exited")
	$enemy/attack_area.connect("body_entered",self,"attack_entered")
	$enemy/attack_area.connect("body_exited",self,"attack_exited")
	
	randomize()
	timer += rand_range(0, refresh_rate)

func _physics_process(delta):
	direction = Vector3()

	if walking_to_spawn == true:
		walk_toward($spawnpoint,delta)
	else:
		if chase == true:
			if player_attack_area == false:
				walk_toward(player,delta)
		elif player_attack_area == false && animplayer.current_animation != "hurt":
			animplayer.play("idle")

	var accel = acceleration if $enemy.is_on_floor() else air_acceleration
	if $enemy.is_on_floor():
		y_velocity = -0.01
	else:
		y_velocity = clamp(y_velocity - gravity, -max_terminal_velocity, max_terminal_velocity)

	velocity = velocity.linear_interpolate(direction * speed, acceleration * delta)
	direction = direction.normalized()
	velocity = direction * speed
	velocity.y = y_velocity
	
	if direction != Vector3():
		$enemy.move_and_slide(velocity,Vector3.UP)
	
	#LOD VİSİBLE
	if timer <= refresh_rate:
		timer += delta
		return

	timer = 0.0
	
	var camera := get_viewport().get_camera()
	if camera == null:
		return
	var distance := camera.global_transform.origin.distance_to(global_transform.origin)
	
	if distance > 100:
		visible = false
	else:
		visible = true

		
func spawnpoint_entered(body):
	on_spawn_point = true
	walking_to_spawn = false

func spawnpoint_exited(body):
	on_spawn_point = false

func spawn_exited(body):
	if body == $enemy:
		walking_to_spawn = true
		chase = false

func look_entered(body):
	if body == player && !Death.dead:
		chase = true
		
func attack_exited(body):
	if body == player && !Death.dead:
		player_attack_area = false
		chase_delay_timer.start()
		shoot_timer.stop()
	
func attack_entered(body):
	if body == player && !Death.dead:
		chase = false
		animplayer.play("idle")
		shoot_timer.start()
		player_attack_area = true

func walk_toward(point,delta):
	direction = point.global_transform.origin - $enemy.global_transform.origin
	$enemy.rotation.y = lerp_angle($enemy.rotation.y, atan2(direction.x,direction.z),delta * 5)
	animplayer.play("walk")

func shoot():
	if !Death.dead:
		if animplayer.current_animation != "hurt":
			animplayer.play("attack")

func finish_anim(anim_name):
	animplayer.play("idle")

func chase_delay_timeout():
	if player_attack_area == false && walking_to_spawn == false && !Death.dead:
		chase = true

#func loop_meshes(parent) -> Array:
#	var arr = []
#	for child in parent.get_children():
#		if child.get_class() == "MeshInstance":
#			arr.append(child)
#		if child.get_child_count() > 0:
#			arr += loop_meshes(child)
#	return arr

func hurt(power):
	if chase == false:
		chase = true
	health -= power
	animplayer.play("hurt")
	if health <= 0:
		animplayer.play("death")
		$enemy/lock.visible = false
		healthbar.queue_free()
		var combat = player.get_node("combat")
		combat.attackers.erase($enemy)
		combat.dashers.erase($enemy)
		combat.hitable.erase($enemy)
		$enemy.name = "enemy-dead"
		set_script(null)

func hit():
	var power = CalcPower.get_power(hit_power,power_chance)
	if player_attack_area:
		if !Death.dead:
			player.get_node("combat").hurt(power)

func on_player_death():
	chase = false
	if on_spawn_point == false:
		walking_to_spawn = true
	player_attack_area = false

