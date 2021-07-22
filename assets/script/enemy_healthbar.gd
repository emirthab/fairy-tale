extends Spatial

onready var enemy = get_parent().get_parent()
onready var max_health = enemy.get("health")
onready var current_health = max_health

func _process(delta):
	var resultant = (current_health / max_health)
	$inside.get_surface_material(0).set_shader_param("Offset.x",resultant)
