extends Spatial

onready var enemy = get_parent().get_parent()
onready var max_health = enemy.get("health")
var current_health

func _process(delta):
	current_health = enemy.get("health")
	var resultant = (float(current_health) / float(max_health))
	print(resultant)
	print(current_health)
	$inside.get_surface_material(0).set_shader_param("offset",Vector3(resultant,0,0))
