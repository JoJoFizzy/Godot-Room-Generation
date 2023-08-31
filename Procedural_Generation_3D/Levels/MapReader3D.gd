extends Spatial

class_name MapReader3D

#PUBLIC:

func init(player : Player, level : Level) -> void:
	
	assert(player, "player is NULL")
	assert(level, "level is NULL")
	
	self._player = player
	self._level = level
	
	change_level(_level)
	
func execute() -> void:
	pass
	
func change_level(level : Level) -> void:

	_clean_level_3d()
	_draw_level_3d(level)

#PRIVATE:

const _room_wall = preload("res://Prefabs/WallRoom.tscn")
const _room_middle = preload("res://Prefabs/MiddleRoom.tscn")
const _room_door = preload("res://Prefabs/DoorRoom.tscn")
const _corridor_corner = preload("res://Prefabs/CorridorCorner.tscn")
const _corridor_hallway = preload("res://Prefabs/CorridorHallway.tscn")
const _corridor_middle = preload("res://Prefabs/CorridorMiddle.tscn")
const _corridor_side = preload("res://Prefabs/CorridorSide.tscn")

onready var _enviroment = $Enviroment
var _player = null
var _level = null


func _draw_level_3d(level : Level) -> void:
	
	var map : Array = level.map.map
	
	for x in map.size():
		for y in map[x].size():
			
			var location = map[x][y]
			
			_set_prefabs(location)
	
func _clean_level_3d() -> void:
	
	for child in _enviroment.get_children():
		
		child.queue_free()
		
	var map : Array = _level.map.map
	
	for x in map.size():
		for y in map[x].size():
			
			var location = map[x][y]
			
			location.instanced_scene = null
			
func _place_prefab(location : Location, scene : Spatial, degrees : float):

		var start_x = location.get_x() * GC.SPATIAL_UNIT_3D
		var start_y = location.get_y() * GC.SPATIAL_UNIT_3D
		
		var width = float(GC.SPATIAL_UNIT_3D) / 2 # from origin
		var height = float(GC.SPATIAL_UNIT_3D) / 2 # from origin
		scene.scale = Vector3(width, GC.SPATIAL_UNIT_3D, height)
			
		scene.transform.origin = Vector3(start_y - height/2, 0, start_x - width/2)
		scene.rotation_degrees = Vector3(0, degrees, 0)
		
		location.instanced_scene = scene
		_enviroment.add_child(scene)	
		
func _set_prefabs(location : Location):
		
	assert(location, "location is NULL")
	
	# wall for room
	if (location.has_tag(GC.TAGS.WALL)):
					
		_place_prefab(location, _room_wall.instance(), 0)
		return
			
	# middle of room
	if (location.has_tag(GC.TAGS.ROOM) && !location.has_tag(GC.TAGS.WALL) && !location.has_tag(GC.TAGS.DOOR)):
		
		_place_prefab(location, _room_middle.instance(), 0)
		return
				
	# doorway for room
	if (location.has_tag(GC.TAGS.DOOR)):
		
		# doorway on left or right of room
		if (location.above && location.below):
			
			# doorway on left side
			if (location.right.has_tag(GC.TAGS.ROOM) && !location.right.has_tag(GC.TAGS.WALL)):
				
				_place_prefab(location, _room_door.instance(), 90)
				return
				
			# doorway on right side
			if (location.left.has_tag(GC.TAGS.ROOM) && !location.left.has_tag(GC.TAGS.WALL)):
				
				_place_prefab(location, _room_door.instance(), 270)
				return
				
		# doorway on top or bottom of room
		if (location.left && location.right):
			
			# doorway on top of room
			if (location.below.has_tag(GC.TAGS.ROOM) && !location.below.has_tag(GC.TAGS.WALL)):
				
				_place_prefab(location, _room_door.instance(), 180)
				return
				
			# doorway on bottom of room
			if (location.above.has_tag(GC.TAGS.ROOM) && !location.above.has_tag(GC.TAGS.WALL)):
				
				_place_prefab(location, _room_door.instance(), 0)
				return
				
	# corridors
	if (location.has_tag(GC.TAGS.CORRIDOR)):
				
		# middle of corridors, or a quad junction
		if (location.above && location.below && location.left && location.right):
			if (location.above.has_tag(GC.TAGS.CORRIDOR) && location.below.has_tag(GC.TAGS.CORRIDOR) &&
				location.left.has_tag(GC.TAGS.CORRIDOR) && location.right.has_tag(GC.TAGS.CORRIDOR)):
		
				_place_prefab(location, _corridor_middle.instance(), 0)
				return
			
		# T-junction of corridors
		
		# point up
		if (location.above && location.left && location.right):
			if ((location.above.has_tag(GC.TAGS.CORRIDOR) || location.above.has_tag(GC.TAGS.DOOR)) &&
				(location.left.has_tag(GC.TAGS.CORRIDOR) || location.left.has_tag(GC.TAGS.DOOR)) &&
				(location.right.has_tag(GC.TAGS.CORRIDOR) || location.right.has_tag(GC.TAGS.DOOR))):
					
					_place_prefab(location, _corridor_side.instance(), 180)
					return
					
		# point down
		if (location.below && location.left && location.right):
			if ((location.below.has_tag(GC.TAGS.CORRIDOR) || location.below.has_tag(GC.TAGS.DOOR)) &&
				(location.left.has_tag(GC.TAGS.CORRIDOR) || location.left.has_tag(GC.TAGS.DOOR)) &&
				(location.right.has_tag(GC.TAGS.CORRIDOR) || location.right.has_tag(GC.TAGS.DOOR))):
					
					_place_prefab(location, _corridor_side.instance(), 0)
					return
					
		# point left
		if (location.left && location.above && location.below):
			if ((location.left.has_tag(GC.TAGS.CORRIDOR) || location.left.has_tag(GC.TAGS.DOOR)) &&
				(location.above.has_tag(GC.TAGS.CORRIDOR) || location.above.has_tag(GC.TAGS.DOOR)) &&
				(location.below.has_tag(GC.TAGS.CORRIDOR) || location.below.has_tag(GC.TAGS.DOOR))):
					
					_place_prefab(location, _corridor_side.instance(), 90)
					return
					
		# point right
		if (location.right && location.above && location.below):
			if ((location.right.has_tag(GC.TAGS.CORRIDOR) || location.right.has_tag(GC.TAGS.DOOR)) &&
				(location.above.has_tag(GC.TAGS.CORRIDOR) || location.above.has_tag(GC.TAGS.DOOR)) &&
				(location.below.has_tag(GC.TAGS.CORRIDOR) || location.below.has_tag(GC.TAGS.DOOR))):
					
					_place_prefab(location, _corridor_side.instance(), 270)
					return
					
		# corridor corners
		
		# top left corridor corner
		if (location.below && location.right):
			if((location.below.has_tag(GC.TAGS.CORRIDOR) || location.below.has_tag(GC.TAGS.DOOR)) &&
				(location.right.has_tag(GC.TAGS.CORRIDOR) || location.right.has_tag(GC.TAGS.DOOR))):
					
					_place_prefab(location, _corridor_corner.instance(), 0)
					return
					
		# top right corridor corner
		if (location.below && location.left):
			if((location.below.has_tag(GC.TAGS.CORRIDOR) || location.below.has_tag(GC.TAGS.DOOR)) &&
				(location.left.has_tag(GC.TAGS.CORRIDOR) || location.left.has_tag(GC.TAGS.DOOR))):
					
					_place_prefab(location, _corridor_corner.instance(), 90)
					return
					
		# bottom left corridor corner
		if (location.above && location.right):
			if((location.above.has_tag(GC.TAGS.CORRIDOR) || location.above.has_tag(GC.TAGS.DOOR)) &&
				(location.right.has_tag(GC.TAGS.CORRIDOR) || location.right.has_tag(GC.TAGS.DOOR))):
					
					_place_prefab(location, _corridor_corner.instance(), 270)
					return
					
		# bottom right corridor corner
		if (location.above && location.left):
			if((location.above.has_tag(GC.TAGS.CORRIDOR) || location.above.has_tag(GC.TAGS.DOOR)) &&
				(location.left.has_tag(GC.TAGS.CORRIDOR) || location.left.has_tag(GC.TAGS.DOOR))):
					
					_place_prefab(location, _corridor_corner.instance(), 180)
					return
					
		# corridor hallway
		
		# up to down corridor hallway
		if (location.above && location.below):
			if ((location.above.has_tag(GC.TAGS.CORRIDOR) || location.above.has_tag(GC.TAGS.DOOR)) &&
				(location.below.has_tag(GC.TAGS.CORRIDOR) || location.below.has_tag(GC.TAGS.DOOR))):
					
					_place_prefab(location, _corridor_hallway.instance(), 90)
					
		# left to right corridor hallway
		if (location.left && location.right):
			if ((location.left.has_tag(GC.TAGS.CORRIDOR) || location.left.has_tag(GC.TAGS.DOOR)) &&
				(location.right.has_tag(GC.TAGS.CORRIDOR) || location.right.has_tag(GC.TAGS.DOOR))):
					
					_place_prefab(location, _corridor_hallway.instance(), 0)
				
		
	
	
