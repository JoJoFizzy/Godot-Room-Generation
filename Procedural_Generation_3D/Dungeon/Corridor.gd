extends Node
class_name Corridor

#PUBLIC:

var entry_location : Location = null
var exit_location : Location = null
var location_path = [] # array of locations for each point of the corridor between entry and exit


func init(entry_location : Location, exit_location : Location, location_path : Array):
	
	assert(entry_location, "entry_location is NULL")
	assert(exit_location, "exit_location is NULL")
	
	self.entry_location = entry_location
	self.exit_location = exit_location
	self.location_path = location_path
	
	_stop_at_intersect()
	_add_corridor_tags()
	
func in_corridor(location : Location) -> bool:
	
	for loc in location_path:
		
		if (location.equals(loc)):
			return true
			
	return false

#PRIVATE:

func _add_corridor_tags() -> void:
	
	for location in location_path:

		location.add_tag(GC.TAGS.CORRIDOR)
		
func _stop_at_intersect() -> void: # makes the corridor stop at an intersection if it intersects with another corridor
								   # call before adding the tags
	for i in range(location_path.size()):

		if (location_path[i].has_tag(GC.TAGS.CORRIDOR)):
			
			exit_location = location_path[i]
			location_path = location_path.slice(0, i)
			break
			
	return
