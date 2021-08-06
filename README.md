<p align="center">
  <a href="https://github.com/emirthab/fairy-tale">
    <img src="https://github.com/emirthab/fairy-tale/blob/main/assets/textures/logo.png?raw=true" alt="Fairy Tale" width="600">
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

### :large_blue_circle: Player Movement:
* "W,A,S,D" keys for movement, "Shift" to run fast and "Space" to jump.

### :large_blue_circle: Autofocus On The Enemy:
* Inside the character node is a node named "target". Changes the rotation based on the "direction" value. 
* A focus mark appears on the enemy closest to this target. Our character's next attack will be in this focus direction.

### :large_blue_circle: Attack Power System:
* Attack power is calculated in the "calc_power.gd" script.  
* Returns a random attack power based on the "power" and "luck" values entered in the "get_power" function.  

## :large_blue_circle:  Billboard Health Bar For Enemies:
* Located inside the enemy node. 
* Drawing "ShaderMaterial" taking "health" data from the enemy on the master node. 
* This picture always looks towards the camera.

## :large_blue_circle: Lod System:
* Their quality deteriorates as they move away from trees and houses. 
* This is an important system for optimizing and values can be changed in the editor.
<p align="left">
    <img src="https://yasirkula.files.wordpress.com/2020/10/monkeylodcrossfadeanimated.gif" alt="lod" height="300">
</p>

### :large_blue_circle: Blur And Dark Screen When Character Dies
### :large_blue_circle: Attack Sounds And Game Music
### :large_blue_circle: Smooth Camera Mechanics (interpolated)
### :large_blue_circle: Combat Mechanics like Dark Souls




#### Thanks!:  
https://github.com/Zylann/godot_scatter_plugin  
https://github.com/Zylann/godot_heightmap_plugin  
https://github.com/Arnklit/Waterways  
