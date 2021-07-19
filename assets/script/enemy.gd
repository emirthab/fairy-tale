extends Spatial

onready var player = get_node("../player")
var chase = false
var walking_to_spawn = false
var player_attack_area = false
var direction = Vector3()

export var speed = 6
export var cooldown = 2

var shoot_timer = Timer.new()

func _ready():
	shoot_timer.wait_time = cooldown
	shoot_timer.connect("timeout",self,"shoot") 
	shoot_timer.one_shot = false
	add_child(shoot_timer)

	$enemy/model/AnimationPlayer.connect("animation_finished",self,"finish_anim")
	$spawnpoint.connect("body_entered",self,"spawnpoint_entered")	
	$enemy/look_area.connect("body_entered",self,"look_entered")
	$spawnarea.connect("body_exited",self,"spawn_exited")
	$enemy/attack_area.connect("body_entered",self,"attack_entered")
	$enemy/attack_area.connect("body_exited",self,"attack_exited")

func _physics_process(delta):

	if walking_to_spawn == true:
		walk_toward($spawnpoint,delta)
	else:
		if chase == true:
			if player_attack_area == false:
				walk_toward(player,delta)
		else:
			$enemy/model/AnimationPlayer.play("idle")

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
	
func attack_entered(body):
	if body == player:
		$enemy/model/AnimationPlayer.play("idle")
		$enemy/model/AnimationPlayer.play("attack")
		shoot_timer.start()
		player_attack_area = true

func walk_toward(point,delta):
	direction = point.global_transform.origin - $enemy.global_transform.origin
	$enemy.rotation.y = lerp_angle($enemy.rotation.y, atan2(direction.x,direction.z),delta * 5)
	#$enemy.look_at($enemy.global_transform.origin - direction,Vector3.UP)
	$enemy.move_and_collide(direction.normalized() * speed * delta)
	$enemy/model/AnimationPlayer.play("walk")

func shoot():
	$enemy/model/AnimationPlayer.play("attack")

func finish_anim(anim_name):
	$enemy/model/AnimationPlayer.play("idle")