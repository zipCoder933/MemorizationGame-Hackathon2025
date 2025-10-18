extends RigidBody3D
@onready var animation_player: AnimationPlayer = $Knight/AnimationPlayer
@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D

#camera
@export var phantom_camera_3d: PhantomCamera3D;
var camRotation = Vector3(0, 0, 0)
var cameraSensitivity:float = 60;
var cameraHorizontalOffset:float = 0
var cameraHorizontalOffsetLerp:float = 0.01

#movement
var movement:Vector3 = Vector3.ZERO;
var is_on_floor:bool = false
const SPEED = 300;
const TURN_SPEED = 5;
var targetRotation:float;
const ROTATION_LERP_SPEED = 0.2;


func _ready():
	pass
	
func _process(delta:float):
	#update camera pan/tilt around the player
	var screen_size = get_viewport().get_visible_rect().size
	var mouse_pos = get_viewport().get_mouse_position()
	var normalized_pos = -((mouse_pos / screen_size) * 2.0 - Vector2(1, 1))
	cameraHorizontalOffset = lerp_angle(cameraHorizontalOffset, rotation.y, cameraHorizontalOffsetLerp)
	camRotation.y = 180 + rad_to_deg(cameraHorizontalOffset) + (normalized_pos.x * cameraSensitivity)
	camRotation.x = -20 + (normalized_pos.y * cameraSensitivity)
	phantom_camera_3d.set_third_person_rotation_degrees(camRotation)
	
func _physics_process(delta: float) -> void:
	#For top down third person movement
	#linear_velocity.x = movement.x * SPEED * delta;
	#linear_velocity.z = movement.z  * SPEED * delta;
	#targetRotation = atan2(linear_velocity.x, linear_velocity.z)
	#rotation.y = lerp_angle(rotation.y, targetRotation, ROTATION_LERP_SPEED)

	#for immersive third person movement
	
	#var forward = transform.basis.z.normalized()  # Godot's "forward" is -Z
	var forward = Vector3.FORWARD.rotated(Vector3.RIGHT, phantom_camera_3d.get_third_person_rotation().x).rotated(Vector3.UP, phantom_camera_3d.get_third_person_rotation().y).normalized()
	
	if(movement.z == 0):
		rotation.y = lerp_angle(rotation.y , targetRotation, delta * TURN_SPEED)
		linear_velocity.x = forward.x * (abs(movement.x) * SPEED * delta)
		linear_velocity.z = forward.z * (abs(movement.x) * SPEED * delta)
	elif(movement.z < 0):
		rotation.y = lerp_angle(rotation.y , targetRotation, delta * TURN_SPEED)
		linear_velocity.x = forward.x * (abs(movement.z) * SPEED * delta)
		linear_velocity.z = forward.z * (abs(movement.z) * SPEED * delta)
	else:
		targetRotation = rotation.y
		rotation.y += movement.x * movement.z * delta * TURN_SPEED
		linear_velocity.x = forward.x * (abs(movement.z) * SPEED * delta)
		linear_velocity.z = forward.z * (abs(movement.z) * SPEED * delta)


	if( linear_velocity.y > 0.5 ):
		animation_player.play("jump Retarget",1)
	elif(abs(linear_velocity.x) > 0 or abs(linear_velocity.z) > 0):
		animation_player.play("running Retarget",1)
	else:
		animation_player.play("idle Retarget",1)


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("forward"):
		movement.z = 1;
	elif Input.is_action_just_released("forward"):
		movement.z = 0;
		
	if Input.is_action_just_pressed("backward"):
		movement.z = -1;
		targetRotation = rotation.y+PI;
	elif Input.is_action_just_released("backward"):
		movement.z = 0;
		
	if Input.is_action_just_pressed("left"):
		movement.x = 1;
		if(movement.z == 0):
			targetRotation = rotation.y+PI/2
	elif Input.is_action_just_released("left"):
		movement.x = 0;
		
	if Input.is_action_just_pressed("right"):
		movement.x = -1;
		if(movement.z == 0):
			targetRotation = rotation.y-PI/2
	elif Input.is_action_just_released("right"):
		movement.x = 0;
		
	if is_on_floor == true and Input.is_action_just_pressed("jump"):
		print("jump")
		animation_player.play("jump Retarget",1)
		apply_central_impulse(Vector3(0, 10, 0))
		is_on_floor = false


func _on_body_entered(body: Node) -> void:
	if body is Floor:
		is_on_floor = true
