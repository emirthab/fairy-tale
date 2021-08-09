<p align="center">
  <a href="https://github.com/emirthab/fairy-tale">
    <img src="https://github.com/emirthab/fairy-tale/blob/main/screenshots/logo-readme.png?raw=true" alt="Fairy Tale" width="600">
  </a>
  
  <a href="https://www.youtube.com/watch?v=FfsBgg5n6kA">
    <img src="https://github.com/emirthab/fairy-tale/blob/main/screenshots/youtube.png?raw=true" alt="Fairy Tale" width="450">
  </a>
</p>

# Introduction:

* Fairy Tale is a godot demo game project where a main character with basic player movements and 3 different combat mechanics fights against mushroom-type test enemies in an open world surrounded by mountains and trees.

# Features:

### :large_blue_circle: Enemies:
* Enemies have 3 main areas.  
* 1st area:  
It is the outermost area, when exiting this area, the enemy returns to his spawn.  
* 2nd area:  
is the field of view, when the character enters this area, the enemy is triggered and starts chasing the character and attacking the character.  
* 3rd area:  
when this area hits the character, if the character is inside that area, it takes damage.  

  <img src="https://github.com/emirthab/fairy-tale/blob/main/screenshots/1.jpg?raw=true" alt="Enemies" width="300">

### :large_blue_circle: Player Movement:
* "W,A,S,D" keys for movement, "Shift" to run fast and "Space" to jump.

### :large_blue_circle: Autofocus On The Enemy:
* Inside the character node is a node named "target". Changes the rotation based on the "direction" value. 
* A focus mark appears on the enemy closest to this target. Our character's next attack will be in this focus direction.

### :large_blue_circle: Attack Power System:
* Attack power is calculated in the "calc_power.gd" script.  
* Returns a random attack power based on the "power" and "luck" values entered in the "get_power" function.  

### :large_blue_circle:  Billboard Health Bar For Enemies:
* Located inside the enemy node. 
* Drawing "ShaderMaterial" taking "health" data from the enemy on the master node. 
* This picture always looks towards the camera.

    <img src="https://github.com/emirthab/fairy-tale/blob/main/screenshots/billboard.gif?raw=true" alt="Enemies" width="300">

### :large_blue_circle: Lod System:
* Their quality deteriorates as they move away from trees and houses. 
* This is an important system for optimizing and values can be changed in the editor.

    <img src="https://yasirkula.files.wordpress.com/2020/10/monkeylodcrossfadeanimated.gif" alt="lod" width="300">


### :large_blue_circle: Blur And Dark Screen When Character Dies:

```gdscript
#on "assests/script/death.gd" :
func death_envs(delta):
	if env.dof_blur_far_amount < death_env_blur_amount:
		env.dof_blur_far_amount += delta * 0.01
	if env.adjustment_saturation > death_env_saturation:
		env.adjustment_saturation -= delta * 0.6
	if env.adjustment_brightness > death_env_brightness:
		env.adjustment_brightness -=  delta * 0.1
```
### :large_blue_circle: Attack Sounds And Game Music
### :large_blue_circle: Smooth Camera Mechanics (interpolated):
* The real pivot (the node to which the camera is attached) follows a dummy pivot.
* When the mouse is rotated, actions take place on the dummy pivot.

  <img src="https://raw.githubusercontent.com/franciscop/ola/master/docs/ball.gif" alt="camera interpolation" width="400">
    
```gdscript
#on "assests/script/player_movement.gd" :
	if event is InputEventMouseMotion && Input.get_mouse_mode() != 0 and $ui.game:
		var resultant = sqrt((event.relative.x * event.relative.x )+ (event.relative.y * event.relative.y ))
		var rot = Vector3(-event.relative.y,-event.relative.x,0).normalized()
		puppet_pivot.rotate_object_local(rot , resultant * mouse_sensivity)
		puppet_pivot.rotation.z = clamp(puppet_pivot.rotation.z,deg2rad(-0),deg2rad(0))
		puppet_pivot.rotation.x = clamp(puppet_pivot.rotation.x,deg2rad(-30),deg2rad(30))

func _physics_process(delta):
	if $ui.game:
		#pivot.rotation.z = lerp_angle(pivot.rotation.z, puppet_pivot.rotation.z ,delta * 10)
		pivot.rotation.x = lerp_angle(pivot.rotation.x, puppet_pivot.rotation.x ,delta * 10)
		pivot.rotation.y = lerp_angle(pivot.rotation.y, puppet_pivot.rotation.y ,delta * 10)
		#pivot.rotation = pivot.rotation.linear_interpolate(puppet_pivot.rotation,delta * 10)
		pivot.global_transform.origin = pivot.global_transform.origin.linear_interpolate(character.get_node("RemotePivot").global_transform.origin,delta *2)
```
### :large_blue_circle: Combat Mechanics like Dark Souls

### And more in Fairy Tale...


#### Thanks!:  
https://github.com/Zylann/godot_scatter_plugin  
https://github.com/Zylann/godot_heightmap_plugin  
https://github.com/Arnklit/Waterways  
