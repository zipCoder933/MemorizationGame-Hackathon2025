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
	var coords = Vector3(x, 0, z)
	var entry = get_entry(coords)
	if entry.size() > 0:
		if(keep):
			pass
		else:
			remove_entries(coords)
	else:
		wall(x, z, WALL,z_axis)


enum Direction {XPOS,XNEG,ZPOS,ZNEG}



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
	pass

#THE MAP
const map_start = Vector3(-50,0,-50)
const map_end = Vector3(50,0,50)

var counter:int = 0
var searched: Dictionary = {}
var place  = Vector3(0,0,0)

func findDirectionThatPointsToTarget(end:Vector3) -> Direction:
	#Find the direction that takes us closer to the goal
	var distances = {
		Direction.XPOS: moveIn(place, Direction.XPOS).distance_to(end),
		Direction.XNEG: moveIn(place, Direction.XNEG).distance_to(end),
		Direction.ZPOS: moveIn(place, Direction.ZPOS).distance_to(end),
		Direction.ZNEG: moveIn(place, Direction.ZNEG).distance_to(end)
	}

	# Find the direction with the lowest distance
	var best_dir = null
	var best_dist = INF

	for dir in distances.keys():
		if distances[dir] < best_dist:
			best_dist = distances[dir]
			best_dir = dir
	return best_dir

func pathDirection(direction:Direction, length:int, setBox:bool) -> bool:
	var madeBox = false
	print("Moving in direction: ",direction," length: ",length)
	for j in range(length):
		var tPlace = moveIn(place,direction)#Move temporarily
		print("tplace: ",tPlace)
		var tPlace2 = moveIn(tPlace,direction)#Move again
		var goingX = (direction == Direction.XPOS or direction == Direction.XNEG)
		
		if searched.has(Vector3i(tPlace)) or searched.has(Vector3i(tPlace2)):
			print("We've already been here")
			break
		elif goingX and (get_entry(Vector3(tPlace.x + 0.5,	 0, 	tPlace.z)).size() > 0 or get_entry(Vector3(tPlace.x + 0.5, 0, 	tPlace.z + 1)).size() > 0):
			print("Walls cannot touch")
			break
		elif !goingX and (get_entry(Vector3(tPlace.x, 		 0,	tPlace.z + 0.5,)).size() > 0 or get_entry(Vector3(tPlace.x + 1,	 0,	tPlace.z + 0.5)).size() > 0):
			print("Walls cannot touch")
			break
		else: #Place the box
			place = tPlace
			searched[Vector3i(place)] = true
			madeBox=true
			if(setBox):
				if(direction == Direction.XPOS or direction == Direction.XNEG):
					print("Placed box")
					box(place.x,place.z,false,true)
				else:
					print("Placed box")
					box(place.x,place.z,true,false)
	return madeBox

func _ready():
	place = map_start
	start(map_start.x,map_start.z)
	for i in range(0,1000):
		var direction = Direction[Direction.keys()[randi_range(0,3)]]#random
		if randf() > 0.2: #towards goal
			direction = findDirectionThatPointsToTarget(map_end)
		pathDirection(direction,randi_range(1,5),true)
		
		#if !pathDirection(Direction.XPOS,1,false) and !pathDirection(Direction.XNEG,1,false) and !pathDirection(Direction.ZPOS,1,false) and !pathDirection(Direction.XNEG,1,false):
			#print("No more moves")
			#return
