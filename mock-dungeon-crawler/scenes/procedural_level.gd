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




func wall_x(x:float, z:float, res:Resource) -> Node3D:
	var instance = res.instantiate()
	instance.rotation.y = 0
	add_entry(Vector3(x,0,z), instance)
	return instance

func wall_z(x:float, z:float, res:Resource) -> Node3D:
	var instance = res.instantiate()
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
		wall_x(x, z+0.5, DOOR)
	else: 
		wall_x(x, z+0.5, DOOR)
	
	if removeIfSomethingHere(x+1, z+0.5):
		wall_x(x+1, z+0.5, DOOR)
	else:
		wall_x(x+1, z+0.5, DOOR)
	
	if removeIfSomethingHere(x+0.5, z):
		wall_z(x+0.5, z, DOOR)
	else:
		wall_z(x+0.5, z, DOOR)
	
	if removeIfSomethingHere(x+0.5, z+1):
		wall_z(x+0.5, z+1, DOOR)
	else:
		wall_z(x+0.5, z+1, DOOR)

func box(x:int, z:int, keepX:bool, keepZ:bool):
	if !keepX and removeIfSomethingHere(x, z+0.5):
		if randf() > 0.7:
			wall_x(x, z+0.5, DOOR)
	else:
		wall_x(x, z+0.5, WALL)
	
	if !keepX and removeIfSomethingHere(x+1, z+0.5):
		if randf() > 0.7:
			wall_x(x+1, z+0.5, DOOR)
	else:
		wall_x(x+1, z+0.5, WALL)
	
	if !keepZ and removeIfSomethingHere(x+0.5, z):
		if randf() > 0.7:
			wall_z(x+0.5, z, DOOR)
	else:
		wall_z(x+0.5, z, WALL)
	
	if !keepZ and removeIfSomethingHere(x+0.5, z+1):
		if randf() > 0.7:
			wall_z(x+0.5, z+1, DOOR)
	else:
		wall_z(x+0.5, z+1, WALL)


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
	if(counter*delta > .5):
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
