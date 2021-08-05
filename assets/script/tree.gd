extends Spatial

func _ready():
	var _name = get_child(0).name
	var path = str("res://assets/sprite/environment/trees/" , _name , ".tscn")
	var real_tree = load(path).instance()
	get_parent().call_deferred("add_child", real_tree)
	real_tree.call_deferred("set_global_transform",global_transform)
	queue_free()
	
