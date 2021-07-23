extends Node

func get_power(power,chance) -> int:
	var arr = []
	for i in range(power / 2,power + power / 2 + 1):
		arr.append(i)
	
	var rate = float(100) / float(chance)
	var left = int(arr.size() / rate)
	
	var arr_left = []
	
	for x in range(0,left-1):
		var obj = arr[0]
		arr_left.append(obj)
		arr.remove(0)
	
	randomize()
	var rand =randi() % 100
	
	if rand <= chance:
		randomize()
		var rand2 = randi() % arr.size()
		return(arr[rand2])
	else:
		randomize()
		var rand2 = randi() % arr_left.size()
		return(arr_left[rand2])
