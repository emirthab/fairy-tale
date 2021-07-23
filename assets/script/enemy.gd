extends Spatial

onready var player = get_node("../player")
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

export var speed = 6
export var cooldown = 2
export var chase_delay = 1.6

var shoot_timer = Timer.new()
var chase_delay_timer = Timer.new()

export var health = 150

func _ready():
	var healthbar = preload("res://assets/sprite/enemy_healthbar.tscn").instance()
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

	$enemy/model/AnimationPlayer.connect("animation_finished",self,"finish_anim")
	$spawnpoint.connect("body_entered",self,"spawnpoint_entered")	
	$enemy/look_area.connect("body_entered",self,"look_entered")
	$spawnarea.connect("body_exited",self,"spawn_exited")
	$enemy/attack_area.connect("body_entered",self,"attack_entered")
	$enemy/attack_area.connect("body_exited",self,"attack_exited")

func _physics_process(delta):
	direction = Vector3()

	if walking_to_spawn == true:
		walk_toward($spawnpoint,delta)
	else:
		if chase == true:
			if player_attack_area == false:
				walk_toward(player,delta)
		elif player_attack_area == false && $enemy/model/AnimationPlayer.current_animation != "hurt":
			$enemy/model/AnimationPlayer.play("idle")

	var accel = acceleration if $enemy.is_on_floor() else air_acceleration
	if $enemy.is_on_floor():
		y_velocity = -0.01
	else:
		y_velocity = clamp(y_velocity - gravity, -max_terminal_velocity, max_terminal_velocity)

	velocity = velocity.linear_interpolate(direction * speed, acceleration * delta)
	direction = direction.normalized()
	velocity = direction * speed
	velocity.y = y_velocity
	$enemy.move_and_slide(velocity,Vector3.UP)

func spawnpoint_entered(body):
	walking_to_spawn = false

func spawn_exited(body):
	if body == $enemy:
		walking_to_spawn = true
		chase = false

func look_entered(body):
	if body == player:
		chase = true
		
func attack_exited(body):
	if body == player:
		player_attack_area = false
		chase_delay_timer.start()
	
func attack_entered(body):
	if body == player:
		chase = false
		$enemy/model/AnimationPlayer.play("idle")
		$enemy/model/AnimationPlayer.play("attack")
		shoot_timer.start()
		player_attack_area = true

func walk_toward(point,delta):
	direction = point.global_transform.origin - $enemy.global_transform.origin
	$enemy.rotation.y = lerp_angle($enemy.rotation.y, atan2(direction.x,direction.z),delta * 5)
	#$enemy.look_at($enemy.global_transform.origin - direction,Vector3.UP)
	#$enemy.move_and_collide(direction.normalized() * speed * delta)
	$enemy/model/AnimationPlayer.play("walk")

func shoot():
	$enemy/model/AnimationPlayer.play("attack")

func finish_anim(anim_name):
	$enemy/model/AnimationPlayer.play("idle")

func chase_delay_timeout():
	if player_attack_area == false && walking_to_spawn == false:
		chase = true

func loop_meshes(parent) -> Array:
	var arr = []
	for child in parent.get_children():
		if child.get_class() == "MeshInstance":
			arr.append(child)
		if child.get_child_count() > 0:
			arr += loop_meshes(child)
	return arr
	
func hurt(power):
	if chase == false:
		chase = true
	health -= power
	$enemy/model/AnimationPlayer.play("hurt")
	
	
