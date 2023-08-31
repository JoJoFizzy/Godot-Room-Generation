extends Node
class_name LevelManager

#PUBLIC:

onready var map_reader_2d = $MapReader2D
onready var map_reader_3d = $MapReader3D
onready var player = $MapReader3D/Player
var current_level : Level = null
var previous_level : Level = null

func init() -> void:
	 pass
	
func update() -> void:
	
	if (current_level):
		
		current_level.execute()
		
		if (map_reader_2d):
			
			map_reader_2d.execute()
			
		if (map_reader_3d):
			
			map_reader_3d.execute()
		
func change_level(new_level : Level) -> void:
	
	assert(new_level, "new_level in change_level() is NULL")

	if (current_level):
		
		previous_level = current_level
		current_level.exit()
		current_level = new_level
		current_level.enter()
		
	else:
		
		previous_level = null
		current_level = new_level
		current_level.enter()
			
	map_reader_2d.init(player, current_level)
	map_reader_3d.init(player, current_level)
	
func revert_to_previous_level() -> void:
	
	if (previous_level):
		
		change_level(previous_level)
		
func is_level(level : Level) -> bool:
	
	assert(level, "level in is_level() is NULL")
	return (current_level.level_name == level.level_name)

#PRIVATE:
