extends StaticBody3D
class_name DoorTrigger

@onready var dungeon_door: Node3D = $"../dungeon_door"
var door_open:float = 3
var door_closed:float = 0
var open:bool = false
const slide_speed = 1;

func open_door(open2:bool):
	open = open2;
		
func _process(delta):
	if open and dungeon_door.position.y < door_open:
		dungeon_door.position.y = dungeon_door.position.y + (slide_speed*delta);
	elif !open and dungeon_door.position.y > door_closed:
		dungeon_door.position.y = dungeon_door.position.y - (slide_speed*delta);
