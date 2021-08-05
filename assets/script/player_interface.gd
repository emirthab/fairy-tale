extends Control

export var game = false
onready var player = get_parent().get_node("combat")
onready var max_health = player.get("health")
var current_health

var camera_interpolation = false

onready var scene = get_tree().get_current_scene()
onready var env = scene.get_node("WorldEnvironment").environment

var timer = Timer.new()

func _ready():
	#scene.get_node("theme_sound").playing = true
	timer.one_shot = true
	timer.wait_time = 2
	timer.connect("timeout",self,"gameStartTimeout")
	add_child(timer)
	
func _process(delta):
	current_health = player.get("health")
	var resultant = -(float(current_health) / float(max_health))
	if current_health <= 0 :
		resultant = 0
	$healthbar/inside.material.set_shader_param("offset",Vector3(resultant,0,0))

func _physics_process(delta):
	if game == true:
		if env.dof_blur_far_amount > 0:
			env.dof_blur_far_amount -= delta * 0.01


func _on_Button_button_down():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$main_anchor.visible = false
	camera_interpolation = true
	timer.start()
	
func gameStartTimeout():
	game = true
