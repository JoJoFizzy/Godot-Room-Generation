extends Node
class_name Location

#PUBLIC:

var above : Location = null # Location above current in array
var below : Location = null # Location below current in array
var left : Location  = null # Location to left of current in array
var right : Location = null # Location to right of current in array

# For pathfinding algorithims, ensure to reset after done with pathfinding
var visited : bool = false  
var global_goal : float = INF
var local_goal : float = INF
var parent : Location = null
var instanced_scene : Spatial = null


func init(position : Vector2) -> void:
	
	self._position = position
	add_tag(GC.TAGS.EMPTY) # user should not have control over empty tag outside this class
	
func get_x() -> int:
	
	return int(_position.x)
	
func get_y() -> int:
	
	return int(_position.y)
	
func has_tag(tag : int) -> bool: # enum in GlobalConstants.gd
	
	return _tags.has(tag)
	
func has_tags(tags : Array) -> bool: 
	
	for tag in tags:
		
		if (has_tag(tag)):
			
			return true
			
	return false
	
func add_tag(tag : int) -> void:
	
	if (!has_tag(tag)): # ensure no duplicates are added
		
		if (has_tag(GC.TAGS.EMPTY)):
			_remove_empty_tag()
			
		_tags.append(tag)
		
		_filter_incompatible_tags(tag)
	
func remove_tag(tag : int) -> void:
	
	if (tag == GC.TAGS.EMPTY):
		return
		
	_tags.erase(tag)
	
	if (_tags.size() == 0):
		add_tag(GC.TAGS.EMPTY)
		
func reset() -> void:
	
	visited = false
	global_goal = INF
	local_goal = INF
	parent = null
		
func get_neighbors(include_visited : bool, filter_tags : Array) -> Array:
	
	var neighbors = []
	
	if (include_visited):
		
		if (above && !above.has_tags(filter_tags)):
			neighbors.append(above)
		if (below && !below.has_tags(filter_tags)):
			neighbors.append(below)
		if (left && !left.has_tags(filter_tags)):
			neighbors.append(left)
		if (right && !right.has_tags(filter_tags)):
			neighbors.append(right)
			
	else:
		
		if (above && !above.has_tags(filter_tags) && !above.visited):
			neighbors.append(above)
		if (below && !below.has_tags(filter_tags) && !below.visited):
			neighbors.append(below)
		if (left && !left.has_tags(filter_tags) && !left.visited):
			neighbors.append(left)
		if (right && !right.has_tags(filter_tags) && !right.visited):
			neighbors.append(right)
			
	return neighbors
		
func equals(target_location : Location) -> bool: # see if they are in the same position
	
	assert(target_location, "target_location is NULL")
	
	if (get_x() == target_location.get_x() && get_y() == target_location.get_y()):
		return true
		
	return false
	
func has_neighbor(target_location : Location) -> bool:
	
	assert(target_location, "target_location is NULL")
	
	var neighbors = []
	
	if (above):
		neighbors.append(above)
	if (below):
		neighbors.append(below)
	if (left):
		neighbors.append(left)
	if (right):
		neighbors.append(right)
		
	if (neighbors.size() == 0):
		return false
		
	for location in neighbors:
		
		if (equals(target_location)):
			
			return true
			
	return false
	
#PRIVATE:

var _position : Vector2 = Vector2.ZERO # index in array
var _tags : Array = [] # Tags to discriminate between locations


func _remove_empty_tag() -> void:
	
	_tags.erase(GC.TAGS.EMPTY)
	
func _filter_incompatible_tags(tag : int) -> void:
	
	match tag:
		
		GC.TAGS.ROOM:
			
			remove_tag(GC.TAGS.CORRIDOR)
			
		GC.TAGS.WALL:
			
			remove_tag(GC.TAGS.CORRIDOR)
			
		GC.TAGS.DOOR:
			
			remove_tag(GC.TAGS.CORRIDOR)
			remove_tag(GC.TAGS.ROOM)
			remove_tag(GC.TAGS.WALL)
			
		GC.TAGS.CORRIDOR:
			
			remove_tag(GC.TAGS.ROOM)
			remove_tag(GC.TAGS.WALL)
			remove_tag(GC.TAGS.DOOR)
			
		GC.TAGS.EMPTY:
			
			remove_tag(GC.TAGS.ROOM)
			remove_tag(GC.TAGS.WALL)
			remove_tag(GC.TAGS.DOOR)
			remove_tag(GC.TAGS.CORRIDOR)
