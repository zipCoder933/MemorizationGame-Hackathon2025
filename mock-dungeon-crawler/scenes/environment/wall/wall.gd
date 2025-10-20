extends StaticBody3D
class_name Wall
const WALL_SIZE = 5
const WALL_THICKNESS = 0.5
#@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
#@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
#
#
#func _ready():
	#var aabb = mesh_instance_3d.mesh.get_aabb()               # Get the mesh's local AABB
	#var box_shape = BoxShape3D.new()         # Create a box shape
	#box_shape.size = aabb.size               # Set the size to match the mesh AABB
	#collision_shape_3d.shape = box_shape     # Assign the shape
	##collision_shape_3d.position = aabb.size / 2
	##print("Collision size: ",collision_shape_3d.shape,"position",collision_shape_3d.position)
