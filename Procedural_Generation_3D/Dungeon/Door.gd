extends Node
class_name Door

#PUBLIC:

var location : Location = null


func init(location : Location) -> void:
	
	assert(location, "location for door is NULL")
	
	self.location = location
	
	_add_door_tag()

#PRIVATE:

func _add_door_tag() -> void:
	
	location.add_tag(GC.TAGS.DOOR)
