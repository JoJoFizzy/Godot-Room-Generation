extends Spatial

class_name Player

#PUBLIC:

onready var camera = $Camera

#PRIVATE

func _input(event):
	
	if (event is InputEventMouseMotion):
		
		camera.rotation_degrees.x -= event.relative.y
		camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -90, 90)
		
		camera.rotation_degrees.y -= event.relative.x
		
func _process(delta):
	
	var move_direction = Vector3.ZERO
	
	if Input.is_action_pressed("move_forwards"):
		move_direction += -camera.global_transform.basis.z
	if Input.is_action_pressed("move_backwards"):
		move_direction += camera.global_transform.basis.z
	if Input.is_action_pressed("move_left"):
		move_direction += -camera.global_transform.basis.x
	if Input.is_action_pressed("move_right"):
		move_direction += camera.global_transform.basis.x
	
	self.global_transform.origin += move_direction * 10 * delta
