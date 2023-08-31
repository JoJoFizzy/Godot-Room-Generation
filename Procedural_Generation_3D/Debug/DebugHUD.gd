extends Control
class_name DebugHUD

#PUBLIC:

func init(level_manager : LevelManager) -> void:
	
	if (!self.visible):
		return
		
	_level_manager = level_manager
	_set_map_to_current_level_map()
	_set_room_list_to_current_level_room_list()
	_print_map()
	_print_room_start_points()
	_print_if_rooms_overlap()
	
func update() -> void:
	
	if (!self.visible):
		return
		
	_set_map_to_current_level_map()

#PRIVATE:

const _TEST = "T"
const _EMPTY = "."
const _ROOM = "X"
const _WALL = "+"
const _CORRIDOR = "0"
const _DOOR = "$"
const _VISITED = "V"

onready var _debug_map : Label = $DebugMap
var _level_manager : LevelManager = null
var _map : Map = null
var _room_list = []

func _set_map_to_current_level_map() -> void:
	
	_map = _level_manager.current_level.map
	
func _set_room_list_to_current_level_room_list() -> void:
	
	_room_list = _level_manager.current_level.room_list

func _print_map() -> void:
	
	var map_string = ""
	
	for x in range(_map.map.size()):
		for y in range(_map.map[x].size()):
			
			var character = ""

			if (_map.map[x][y].has_tag(GC.TAGS.EMPTY)):
				
				character = _EMPTY
				
			if (_map.map[x][y].has_tag(GC.TAGS.ROOM)):
				
				character = _ROOM
				
			if (_map.map[x][y].has_tag(GC.TAGS.WALL)):
				
				character = _WALL
				
			if (_map.map[x][y].has_tag(GC.TAGS.CORRIDOR)):
				
				character = _CORRIDOR
				
			if (_map.map[x][y].has_tag(GC.TAGS.DOOR)):
				
				character = _DOOR
				
			if (_map.map[x][y].visited):
				
				character = _VISITED
				
			if (_map.map[x][y].has_tag(GC.TAGS.TEST)):
				
				character = _TEST
				
			map_string += character
			
		map_string += "\n"
		
	_debug_map.text = map_string
	
func _print_if_rooms_overlap() -> void:
	
	if (_level_manager.current_level.do_any_rooms_overlap()):
		
		print("some rooms overlap")
		
	else:
		
		print("no rooms overlap")
		
func _print_room_start_points():
	
	for room in _room_list:
		
		print("x: " + str(room.start_location.get_x()) + " y: " + str(room.start_location.get_y()))
