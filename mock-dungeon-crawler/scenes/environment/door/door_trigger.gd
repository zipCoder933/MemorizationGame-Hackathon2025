extends StaticBody3D
class_name DoorTrigger

@onready var dungeon_door: Node3D = $"../dungeon_door"
var door_target:float = 0

func open_door(open:bool):
	if(open):
		door_target = 3
	else:
		door_target = 0
		
func _process(delta):
	dungeon_door.position.y = lerp(dungeon_door.position.y,door_target, 1*delta);
