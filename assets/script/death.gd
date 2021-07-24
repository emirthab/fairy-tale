extends Node

signal death_signal

var dead = false

var death_env_blur_amount = 0.09
var death_env_saturation = 0.13
var death_env_brightness = 0.88

onready var scene = get_tree().get_current_scene()
onready var player = scene.get_node("player/combat")

func _physics_process(delta):
	if dead:
		death_envs(delta)

func death_envs(delta):
	var env = scene.get_node("WorldEnvironment").environment
	if env.dof_blur_far_amount < death_env_blur_amount:
		env.dof_blur_far_amount += delta * 0.01
	if env.adjustment_saturation > death_env_saturation:
		env.adjustment_saturation -= delta * 0.6
	if env.adjustment_brightness > death_env_brightness:
		env.adjustment_brightness -=  delta * 0.1

func death():
	dead = true
	player.current_attack == -1
	player.animplayer.play("death")
	emit_signal("death_signal")
