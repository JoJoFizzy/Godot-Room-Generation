extends Node
class_name Map

#PUBLIC:

var map : Array = []
var dimensions = Vector2.ZERO


func init(dimensions : Vector2) -> void:
	
	self.dimensions = dimensions
	_instantiate_array_2D()
	_instantiate_all_locations()
	_link_all_locations()
	
func get_location(position : Vector2) -> Location:
	
	return map[position.x][position.y]
	
func tag_whole_map(tag : int) -> void: # use enum from GlobaConstants.gd
	
	for x in range(dimensions.x):
		for y in range(dimensions.y):
			
			map[x][y].add_tag(tag)
			
func remove_tag_from_whole_map(tag : int) -> void: # use enum from GlobaConstants.gd
	
	for x in range(dimensions.x):
		for y in range(dimensions.y):
			
			map[x][y].remove_tag(tag)
			
func tag_section_of_map(start_location : Location, end_location : Location, tag : int) -> void:
	
	if (start_location.get_x() < 0 || start_location.get_y() < 0 ||
		end_location.get_x() < 0 || end_location.get_y() < 0):
			
		print("start_location or end_location in tag_section_of_map() is negative")
		return
		
	if (end_location.get_x() > dimensions.x || end_location.get_y() > dimensions.y):
		print("end_location in tag_section_of_map() are out of bounds")
		return
		
	if (start_location.get_x() >= end_location.get_x() ||
		start_location.get_y() >= end_location.get_y()):
			
		print("start_location is bigger than end_location in tag_section_of_map()")
		return	
		
	for x in range(start_location.get_x(), end_location.get_x()+1):
		for y in range(start_location.get_y(), end_location.get_y()+1):
			
			map[x][y].add_tag(tag)
			
func reset_all_locations() -> void:
	
	for x in range(dimensions.x):
		for y in range(dimensions.y):
			
			map[x][y].reset()
			
func manhatten_distance(start_location : Location, end_location : Location) -> float:
	
	var abs_diff_x = abs(start_location.get_x() - end_location.get_x())
	var abs_diff_y = abs(start_location.get_y() - end_location.get_y())
	
	return abs_diff_x + abs_diff_y
		
#PRIVATE:

const _LOCATION = preload("res://Utils/Location.gd")


func _instantiate_array_2D() -> void: # make array into 2d array
	
	assert(dimensions != Vector2.ZERO, "dimensions for map not set")
	
	for x in range(dimensions.x):
		
		map.append([])
		
		for y in range(dimensions.y):
			
			map[x].append(0)
		
func _instantiate_all_locations() -> void: # make locations for each position in array
	
	for x in range(dimensions.x):
		for y in range(dimensions.y):
			
			var new_location = _LOCATION.new()
			new_location.init(Vector2(x, y))
			map[x][y] = new_location
			
func _link_all_locations() -> void:
	
	for x in range(1, dimensions.x-1): # link locations not at the bounds of array first
		for y in range(1, dimensions.y-1):
			
			map[x][y].above = map[x][y-1]
			map[x][y].below = map[x][y+1]
			map[x][y].left = map[x-1][y]
			map[x][y].right = map[x+1][y]
			
	for x in range(1, dimensions.x-1): # link top and bottom part of array not including the beginning and end
		
		map[x][0].below = map[x][1]
		map[x][0].left = map[x-1][0]
		map[x][0].right = map[x+1][0]
		
		map[x][dimensions.y-1].above = map[x][dimensions.y-2]
		map[x][dimensions.y-1].left = map[x-1][dimensions.y-1]
		map[x][dimensions.y-1].right = map[x+1][dimensions.y-1]
		
	for y in range(1, dimensions.y-1): # link left and right part of array not including the beginning and end
		
		map[0][y].above = map[0][y-1]
		map[0][y].below = map[0][y+1]
		map[0][y].right = map[1][y]
		
		map[dimensions.x-1][y].above = map[dimensions.x-1][y-1]
		map[dimensions.x-1][y].below = map[dimensions.x-1][y+1]
		map[dimensions.x-1][y].left = map[dimensions.x-2][y]
		
	# link corners of array	
		
	map[0][0].below = map[0][1] # top left corner
	map[0][0].right = map[1][0]
	
	map[0][dimensions.y-1].above = map[0][dimensions.y-2] # bottom left corner
	map[0][dimensions.y-1].right = map[1][dimensions.y-1]
	
	map[dimensions.x-1][0].below = map[dimensions.x-1][1] # top right corner
	map[dimensions.x-1][0].left = map[dimensions.x-2][0]
	
	map[dimensions.x-1][dimensions.y-1].above = map[dimensions.x-1][dimensions.y-2] # bottom right corner
	map[dimensions.x-1][dimensions.y-1].left = map[dimensions.x-2][dimensions.y-1]
			
