extends Node
class_name DungeonRoom

#PUBLIC:

var start_location : Location = null
var end_location : Location = null
var door_list = []


func init(start_location : Location, end_location : Location) -> void:
	
	assert(start_location, "start_location is NULL")
	assert(end_location, "end_location is NULL")
	
	self.start_location = start_location
	self.end_location = end_location
		
func is_in_room(location : Location) -> bool:
	
	# Assume rooms start with their upper left corner as the start position
	# and is the index of a 2D array
	
	if (location.get_x() >= start_location.get_x() &&
		location.get_x() <= end_location.get_x() &&
		location.get_y() >= start_location.get_y() &&
		location.get_y() <= end_location.get_y()):
			
		return true
		
	return false	
	
func add_door(location : Location) -> bool:
	
	if (!is_in_room(location)):
		print("door location not in room")
		return false
		
	if (location.has_tag(GC.TAGS.DOOR)):
		print("location is already door")
		return false
		
	var door : Door = _DOOR.new()
	door.init(location)
	self.add_child(door)
	
	door_list.append(door)
	
	return true
	
func remove_door(door : Door) -> void:
	
	if (!door_list.has(door)):
		print("this door does not exist in this room")
		return
		
	door.location.remove_tag(GC.TAGS.DOOR)
	door_list.erase(door)
	door.delete_door()
	
func get_random_door_location() -> Location:
	# location must not be on the borders of the map, must be on the walls of the room
	# cannot be the corners of a room either
	var potential_location = []
	
	var top_row = start_location.right
	var bottom_row = end_location.left

	for i in range(end_location.get_x() - start_location.get_x() - 1):
		
		potential_location.append(top_row)
		top_row = top_row.right
		
		potential_location.append(bottom_row)
		bottom_row = bottom_row.left
		
	var left_column = start_location.below
	var right_column = end_location.above

	for i in range(end_location.get_y() - start_location.get_y() - 1):

		potential_location.append(left_column)
		left_column = left_column.below
		
		potential_location.append(right_column)
		right_column = right_column.above

	for location in potential_location:
		
		if (location.get_neighbors(true, []).size() < 4): # means there is a neighbor that is null (out of bounds)
			
			potential_location.erase(location)
			
	var random_index = _rng.randi_range(0, potential_location.size()-1)
	return potential_location[random_index]
	

#PRIVATE:

const _DOOR = preload("res://Dungeon/Door.gd")
var _rng = RandomNumberGenerator.new()
