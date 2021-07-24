extends Spatial

onready var enemy = get_parent().get_parent()
onready var max_health = enemy.get("health")
onready var current_health = max_health
onready var new_vector = Vector3((float(current_health) / float(max_health)),0,0)

func _physics_process(delta):
	current_health = enemy.get("health")
	var resultant = (float(current_health) / float(max_health))
	resultant = new_vector.linear_interpolate(Vector3(resultant,0,0),delta * 5)
	new_vector = resultant
	$inside.get_surface_material(0).set_shader_param("offset",resultant)

