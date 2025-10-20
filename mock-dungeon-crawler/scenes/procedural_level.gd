extends Node3D

const WALL = preload("uid://yfkq4t75fea1")
const DOOR = preload("uid://cqlppj7jqrdv3")


"""
The level data
Vector2 -> node list
"""
var data: Dictionary = {}
const WALL_LENGTH =  Wall.WALL_SIZE
const WALL_THICKNESS =  Wall.WALL_THICKNESS
const HALF_WALL_LENGTH =  Wall.WALL_SIZE / 2

#Private
func add_entry(key: Vector3, value: Node) -> void: #Add a node to the array for this Vector2 key
	key = _format_vec3(key)
	value.position = key
	add_child(value)
	
	data[key] = data.get(key, [])
	data[key].append(value)

func get_entry(key: Vector3) -> Array: #Return the array stored at the key (or an empty one if none)
	key = _format_vec3(key)
	return data.get(key, [])

func remove_entries(key: Vector3) -> void:
	for node in get_entry(key): #delete nodes
		node.queue_free()
	data.erase(_format_vec3(key))
	
func clear_entries() -> void:# Remove everything
	for node in data.values():#delete nodes
		node.queue_free()
	data.clear()

func _format_vec3(vec:Vector3) -> Vector3:
	return Vector3(vec.x * WALL_LENGTH, vec.y, vec.z * WALL_LENGTH)

"""
Procedural generation of dungeons:
		Spawn a random enemy, door or chest along the path
	
1. Generate a path from the start position to some ending
2. Generate branches going outward
3. Make a large room on the branches
4. Spawn enemies in the branches 
"""




func wall(x:float, z:float, res:Resource, z_axis:bool) -> Node3D:
	var instance = res.instantiate()
	if(z_axis):
		instance.rotation.y = PI/2
	add_entry(Vector3(x,0,z), instance)
	return instance

func removeIfSomethingHere(x:float, z:float) -> bool:
	if get_entry(Vector3(x,0,z)).size() > 0:
		remove_entries(Vector3(x,0,z))
		return true
	return false
	
func start(x:float, z:float):
	if removeIfSomethingHere(x, z+0.5):
		wall(x, z+0.5, DOOR,false)
	else: 
		wall(x, z+0.5, DOOR,false)
	
	if removeIfSomethingHere(x+1, z+0.5):
		wall(x+1, z+0.5, DOOR,false)
	else:
		wall(x+1, z+0.5, DOOR,false)
	
	if removeIfSomethingHere(x+0.5, z):
		wall(x+0.5, z, DOOR,true)
	else:
		wall(x+0.5, z, DOOR,true)
	
	if removeIfSomethingHere(x+0.5, z+1):
		wall(x+0.5, z+1, DOOR,true)
	else:
		wall(x+0.5, z+1, DOOR,true)


func box(x:int, z:int, keepX:bool, keepZ:bool):
	_place_wall(x, z + 0.5, keepX,false)
	_place_wall(x + 1, z + 0.5, keepX,false)
	_place_wall(x + 0.5, z, keepZ,true)
	_place_wall(x + 0.5, z + 1, keepZ,true)

func _place_wall(x: float, z: float, keep: bool, z_axis:bool) -> void:
	var entry = get_entry(Vector3(x, 0, z))
	if entry.size() > 0:#If there is already a wall here
		if(keep):#If keep walls, just skip it
			if(randf() > 0.5):#replace wall with a door
				if(!z_axis):
					if get_entry(Vector3(x, 0, z-1)).size() > 0 and get_entry(Vector3(x, 0, z+1)).size() > 0:#replace it with a door
						remove_entries(Vector3(x, 0, z))
						wall(x, z, DOOR,z_axis)
				else:
					if get_entry(Vector3(x-1, 0, z)).size() > 0 and get_entry(Vector3(x+1, 0, z)).size() > 0:#replace it with a door
						remove_entries(Vector3(x, 0, z))
						wall(x, z, DOOR,z_axis)
		else:#Otherwise, remove the wall and add a door
			remove_entries(Vector3(x, 0, z))
			var wallPlaced:bool = false
			if(z_axis):
				if get_entry(Vector3(x, 0, z-1)).size() > 0 and get_entry(Vector3(x, 0, z+1)).size() > 0:#replace it with a door
					wall(x, z, DOOR,z_axis)
					wallPlaced=true
			else:
				if get_entry(Vector3(x-1, 0, z)).size() > 0 and get_entry(Vector3(x+1, 0, z)).size() > 0:#replace it with a door
					wall(x, z, DOOR,z_axis)
					wallPlaced=true
			#if !wallPlaced and randf() > 0.8:
				#wall(x, z, DOOR,z_axis)
	else:
		wall(x, z, WALL,z_axis)


enum Direction {XPOS,XNEG,ZPOS,ZNEG}

var counter:int = 0
var searched: Dictionary = {}
var place  = Vector3(0,0,0)

func moveIn(place:Vector3, direction:Direction) -> Vector3:
	if direction == Direction.XPOS:
		place.x +=1
	elif direction == Direction.ZPOS:
		place.z +=1
	elif direction == Direction.XNEG:
		place.x -= 1
	else:
		place.z -=1
	return place

func _process(delta):
	counter+=1
	if(counter*delta > .01):
		placePath()
		counter = 0

func placePath():
	var direction = Direction[Direction.keys()[randi_range(0,3)]]
	for j in range(randi_range(1,4)):
		place = moveIn(place,direction)
		
		if searched.has(Vector3(place)):
			print("walls already here")
			return
		
		#if searched.has(moveIn(Vector3(place),direction)):
			#print("Walls here ahead")
			#return
			
		searched[Vector3(place)] = true
		if(direction == Direction.XPOS or direction == Direction.XNEG):
			box(place.x,place.z,false,true)
		else:
			box(place.x,place.z,true,false)

func _ready():
	start(0,0)
