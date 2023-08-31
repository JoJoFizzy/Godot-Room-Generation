extends Control

class_name MapReader2D

#PUBLIC

func init(player : Player, level : Level) -> void:
	
	assert(player, "player is NULL")
	assert(level, "level is NULL")
	
	_level = level
	_player = player
	_rng.seed = level.level_seed
	
	_adjust_player_start_position()
	change_level(_level)
	
func execute() -> void:
	
	var player_marker_x = _player.transform.origin.x * GC.SPATIAL_UNIT_2D
	var player_marker_y = _player.transform.origin.z * GC.SPATIAL_UNIT_2D
	_player_marker.position = Vector2(player_marker_x, player_marker_y)
	
	var camera_3d_rotation = _player.camera.rotation_degrees.y
	_player_marker.rotation_degrees = -camera_3d_rotation
	
	if Input.is_action_pressed("move_forwards"):
		_player_marker.set_flip_h(false)
		_player_marker.set_animation("Forwards")
	elif Input.is_action_pressed("move_backwards"):
		_player_marker.set_flip_h(false)
		_player_marker.set_animation("Backwards")
	elif Input.is_action_pressed("move_left"):
		_player_marker.set_flip_h(false)
		_player_marker.set_animation("Sideways")
	elif Input.is_action_pressed("move_right"):
		_player_marker.set_flip_h(true)
		_player_marker.set_animation("Sideways")
	else:
		_player_marker.set_flip_h(false)
		_player_marker.set_animation("Idle")
		
func change_level(level : Level) -> void:

	_clean_level_2d()
	_draw_level_2d(level)
	
	
#PRIVATE:

onready var _enviroment = $ViewportContainer/Viewport/Map2D/Enviroment
onready var _player_marker = $ViewportContainer/Viewport/Map2D/PlayerMarker
onready var _player_marker_camera = $ViewportContainer/Viewport/Map2D/PlayerMarker/Camera2D

var _level : Level
var _player : Player
var _rng = RandomNumberGenerator.new()


func _adjust_player_start_position() -> void:
	
	var player_marker_x = _player.transform.origin.x * GC.SPATIAL_UNIT_2D
	var player_marker_y = _player.transform.origin.z * GC.SPATIAL_UNIT_2D
	_player_marker.position = Vector2(player_marker_x, player_marker_y)

func _draw_level_2d(level : Level) -> void:

	var room_list = level.room_list
	var corridor_list = level.corridor_list
	
	for room in room_list:

		var new_rect = ColorRect.new()
		new_rect.color = Color(_rng.randf(), _rng.randf(), _rng.randf(), 0.5)
		
		var start_x = (room.start_location.get_x() - 1) * GC.SPATIAL_UNIT_2D * GC.SPATIAL_UNIT_3D
		var start_y = (room.start_location.get_y() - 1) * GC.SPATIAL_UNIT_2D * GC.SPATIAL_UNIT_3D
		var width = (room.end_location.get_x() - room.start_location.get_x() + 1) * GC.SPATIAL_UNIT_2D * GC.SPATIAL_UNIT_3D
		var height = (room.end_location.get_y() - room.start_location.get_y() + 1) * GC.SPATIAL_UNIT_2D * GC.SPATIAL_UNIT_3D

		new_rect.rect_position = Vector2(start_y, start_x)
		new_rect.rect_size = Vector2(height, width)
		
		_enviroment.add_child(new_rect)
		
		for door in room.door_list:
			
			var door_piece = ColorRect.new()
			door_piece.color = Color(new_rect.color.r / 4, new_rect.color.g / 4, new_rect.color.b / 4, 0.5)
			
			var x_start = (door.location.get_x() - 1) * GC.SPATIAL_UNIT_2D * GC.SPATIAL_UNIT_3D
			var y_start = (door.location.get_y() - 1) * GC.SPATIAL_UNIT_2D * GC.SPATIAL_UNIT_3D
			
			door_piece.rect_position = Vector2(y_start, x_start)
			door_piece.rect_size = Vector2(GC.SPATIAL_UNIT_2D * GC.SPATIAL_UNIT_3D,
										   GC.SPATIAL_UNIT_2D * GC.SPATIAL_UNIT_3D)
										
			_enviroment.add_child(door_piece)
		
		for corridor in corridor_list:
			for location in corridor.location_path:
				
				var corridor_piece = ColorRect.new()
				corridor_piece.color = Color(255.0, 255.0, 255.0, 0.5)
				
				var x_start = (location.get_x() - 1) * GC.SPATIAL_UNIT_2D * GC.SPATIAL_UNIT_3D
				var y_start = (location.get_y() - 1) * GC.SPATIAL_UNIT_2D * GC.SPATIAL_UNIT_3D
				
				corridor_piece.rect_position = Vector2(y_start, x_start)
				corridor_piece.rect_size = Vector2(GC.SPATIAL_UNIT_2D * GC.SPATIAL_UNIT_3D,
												   GC.SPATIAL_UNIT_2D * GC.SPATIAL_UNIT_3D)
				
				_enviroment.add_child(corridor_piece)
		
func _clean_level_2d() -> void:
	
	for child in _enviroment.get_children():
		
		child.queue_free()
