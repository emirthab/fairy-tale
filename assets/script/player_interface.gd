extends Control

onready var player = get_parent()
onready var max_health = player.get("health")
var current_health

func _process(delta):
	current_health = player.get("health")
	var resultant = -(float(current_health) / float(max_health))
	$healthbar/inside.material.set_shader_param("offset",Vector3(resultant,0,0))