extends Node
class_name Level

#PUBLIC:

var level_name : String = ""
var room_list = []
var corridor_list = []
var map : Map = null
var dims = Vector2.ZERO
var level_seed = null


func init(x_dim : int, y_dim : int, level_name : String, level_seed : int) -> void:
	
	self.dims = Vector2(x_dim, y_dim)
	self.level_name = level_name
	self._rng.seed = level_seed
	self.level_seed = level_seed
	
	map = _MAP.new()
	map.init(dims)
	
func enter() -> void:

	_procedurally_generate_rooms()
	_place_rooms()
	_write_rooms_to_map()
	_place_doors()
	_connect_all_doors()
	_cull_rooms()
	
func execute() -> void:
	pass
	
func exit() -> void:
	pass
	
func do_any_rooms_overlap() -> bool:
	
	for room1 in room_list:
		for room2 in room_list:
			
			if (room1 != room2):
				
				if (room1.start_location.get_x() <= room2.end_location.get_x() &&
					room1.start_location.get_x() >= room2.start_location.get_x() &&
					room1.start_location.get_y() <= room2.end_location.get_y() &&
					room1.start_location.get_y() >= room2.start_location.get_y()):
						
						return true
						
				if (room1.end_location.get_x() <= room2.end_location.get_x() &&
					room1.end_location.get_x() >= room2.start_location.get_x() &&
					room1.end_location.get_y() <= room2.end_location.get_y() &&
					room1.end_location.get_y() >= room2.end_location.get_y()):
						
						return true
						
	return false
	

#PRIVATE:

const _MAP = preload("res://Utils/Map.gd")
const _ROOM = preload("res://Dungeon/DungeonRoom.gd")
const _CORRIDOR = preload("res://Dungeon/Corridor.gd")
var _rng = RandomNumberGenerator.new()

func _procedurally_generate_rooms(partition_level = GC.BSP_COUNT) -> void:
	
	if (room_list.size() != 0):
		print("can only generate rooms if no rooms are already generated")
		return
	
	if (GC.MIN_ROOM_SIZE * pow(2, partition_level-1) * 2 > min(dims.x, dims.y)):
			
			print("partition_level incompatible with MIN_ROOM_SIZE")
			var max_partition_level = floor(log(min(dims.x, dims.y) / (2 * GC.MIN_ROOM_SIZE)) / log(2) + 1)
			print("max partition_level is: " + str(max_partition_level))
			return

	var initial_room = _ROOM.new()				# end_points are actual indices not full dimensions
	initial_room.init(map.get_location(Vector2.ZERO), map.get_location(Vector2(dims.x-1, dims.y-1)))
	room_list.append(initial_room)
	
	for i in range(partition_level-1, -1, -1):

		var room_list_size = room_list.size()
		
		for k in range(room_list_size):
			
			var vertical_or_horizontal = _rng.randi_range(0, 1) # 0 for horizontal, 1 for vertical

			if (vertical_or_horizontal == 0): # horizontal
				
				var random_index = 0
				var pad = GC.MIN_ROOM_SIZE * pow(2, i)
				
				random_index = _rng.randi_range(room_list[k].start_location.get_y() + pad-1, 								room_list[k].end_location.get_y() - pad)
				
				var original_end = room_list[k].end_location
				
				# change original room
				var new_end = Vector2(room_list[k].end_location.get_x(), random_index)
				room_list[k].end_location = map.get_location(new_end)
				
				# make new room
				var new_room = _ROOM.new()
				var new_start = Vector2(room_list[k].start_location.get_x(), room_list[k].end_location.get_y()+1)
				new_room.init(map.get_location(new_start), original_end)
				
				room_list.append(new_room)
				
			elif (vertical_or_horizontal == 1): # vertical
				
				var random_index = 0
				var pad = GC.MIN_ROOM_SIZE * pow(2, i)
				
				random_index = _rng.randi_range(room_list[k].start_location.get_x() + pad-1, 								room_list[k].end_location.get_x() - pad)
				
				var original_end = room_list[k].end_location

				# change original room
				var new_end = Vector2(random_index, room_list[k].end_location.get_y())
				room_list[k].end_location = map.get_location(new_end)

				# make new room
				var new_room = _ROOM.new()
				var new_start = Vector2(room_list[k].end_location.get_x()+1, room_list[k].start_location.get_y())
				new_room.init(map.get_location(new_start), original_end)

				room_list.append(new_room)
					
				
func _place_rooms() -> void:
	
	for i in range(room_list.size()):
	
		var width = room_list[i].end_location.get_x() - room_list[i].start_location.get_x()
		var height = room_list[i].end_location.get_y() - room_list[i].start_location.get_y()
		var random_width = _rng.randi_range(GC.MIN_ROOM_SIZE-1, width)
		var random_height = _rng.randi_range(GC.MIN_ROOM_SIZE-1, height)
		
		var random_x = _rng.randi_range(room_list[i].start_location.get_x(), 
										room_list[i].end_location.get_x() - random_width)
		var random_y = _rng.randi_range(room_list[i].start_location.get_y(),
										room_list[i].end_location.get_y() - random_height)
										
		var end_x = random_x + random_width
		var end_y = random_y + random_height
		
		room_list[i].start_location = map.get_location(Vector2(random_x, random_y))
		room_list[i].end_location = map.get_location(Vector2(end_x, end_y))
		
func _cull_rooms() -> void:
	
	# remove doors that arn't connected to anything
	
	for room in room_list:
		for door in room.door_list:
			
			var unconnected_door : bool = true
			
			for corridor in corridor_list:
				
				if (door.location.equals(corridor.entry_location) ||
					door.location.equals(corridor.exit_location)):
						
						unconnected_door = false
				
			if (unconnected_door):
				
					door.location.add_tag(GC.TAGS.EMPTY)
					door.location.add_tag(GC.TAGS.ROOM)
					door.location.add_tag(GC.TAGS.WALL)
					room.door_list.erase(door)
					door.queue_free()
			
	# make list of rooms that are unreachable
	
	var unreachable_rooms = []
	var unreachable_indexes = []
	var filter_tags = [GC.TAGS.WALL, GC.TAGS.EMPTY]
	
	for i in range(room_list.size()-1):
		
		if (unreachable_indexes.find(i) == -1):
		
			for k in range(i+1, room_list.size()):
					
				var start_location = room_list[i].start_location.right.below
				var target_location = room_list[k].start_location.right.below
				var pathway = _get_A_star_search_path(start_location, target_location, filter_tags)
					
				if (pathway.size() == 1):
					
					unreachable_rooms.append(room_list[k])	
					unreachable_indexes.append(k)
		
		
	# remove duplicates rooms from unreachable_rooms
			
	var duplicate_index = []

	for i in range(unreachable_rooms.size()):
		for k in range(i+1, unreachable_rooms.size()):
			
			if (unreachable_rooms[i].start_location.equals(unreachable_rooms[k].start_location)):
				
				duplicate_index.append(i)
				
	var offset = 0
	for index in duplicate_index:
		
		unreachable_rooms.remove(index + offset)
		offset -= 1
		
	# remove rooms that are unreachable
	
	for room in unreachable_rooms:
		for door in room.door_list:
			for corridor in corridor_list:
				
				if (door.location.equals(corridor.entry_location) ||
					door.location.equals(corridor.exit_location)):
						
						for location in corridor.location_path:
							
							location.add_tag(GC.TAGS.EMPTY)
							
						corridor_list.erase(corridor)
						corridor.queue_free()
							
			door.location.add_tag(GC.TAGS.EMPTY)
			room.door_list.erase(door)
			door.queue_free()
			
		map.tag_section_of_map(room.start_location, room.end_location, GC.TAGS.EMPTY)
		room_list.erase(room)
		room.queue_free()
		
	# mop up corridor stragglers
		
	for corridor in corridor_list:
		
		var is_straggler = true
		
		for room in room_list:
			for door in room.door_list:
				
				if (corridor.entry_location.equals(door.location) ||
					corridor.exit_location.equals(door.location)):
						
						is_straggler = false
						
		if (is_straggler):
			
			for location in corridor.location_path:
				location.add_tag(GC.TAGS.EMPTY)
				
			corridor_list.erase(corridor)

func _write_rooms_to_map() -> void:
	
	for room in room_list:

		map.tag_section_of_map(room.start_location, room.end_location, GC.TAGS.ROOM)
		
	_give_room_walls()
		
func _give_room_walls() -> void:
	
	for room in room_list:
		
		for x in range(room.start_location.get_x(), room.end_location.get_x()+1):
		
			var top_boundary : Location = map.get_location(Vector2(x, room.start_location.get_y()))
			top_boundary.add_tag(GC.TAGS.WALL)
			
			var bottom_boundary : Location = map.get_location(Vector2(x, room.end_location.get_y()))
			bottom_boundary.add_tag(GC.TAGS.WALL)
	
		for y in range(room.start_location.get_y(), room.end_location.get_y()+1):
			
			var left_boundary : Location = map.get_location(Vector2(room.start_location.get_x(), y))
			left_boundary.add_tag(GC.TAGS.WALL)
			
			var right_boundary : Location = map.get_location(Vector2(room.end_location.get_x(), y))
			right_boundary.add_tag(GC.TAGS.WALL)
			
func _place_doors() -> void: # must be done after rooms are placed
	
	for room in room_list:
		
		for i in range(GC.NUMBER_OF_DOORS):
			
			var door_added : bool = false
			
			while (!door_added):
				
				var random_location = room.get_random_door_location()
				door_added = room.add_door(random_location)
			
func _connect_all_doors() -> void: # some rooms may not be connnected
	
	var door_list = []
	
	for room in room_list:
		for door in room.door_list:
			
			door_list.append(door)
			
	door_list.shuffle()
	
	for i in range(0, door_list.size(), 2):

		var start_door : Location = door_list[i].location
		var end_door : Location = door_list[i+1].location
		
		_make_corridor(start_door, end_door)
		
	for i in range(1, door_list.size(), 2):
		
		var start_door : Location = door_list[i].location
		var end_door : Location = door_list[i-1].location 
		
		_make_corridor(start_door, end_door)					
			
func _make_corridor(start_location : Location, target_location : Location) -> bool:

	var filter_tags = [GC.TAGS.ROOM, GC.TAGS.WALL]
	var pathway = _get_A_star_search_path(start_location, target_location, filter_tags)

	if (pathway.size() == 1 && pathway.front().equals(start_location)): # Path was not found
		return false
		
	var corridor = _CORRIDOR.new()
	corridor.init(pathway.pop_front(), pathway.pop_back(), pathway)
	corridor_list.append(corridor)
	
	return true
			
# A* algorithim inspired by javidx9 on YouTube, he has great tutorials
func _get_A_star_search_path(start_location : Location, target_location : Location, filter_tags : Array) -> Array:
	
	assert(start_location, "start_location is NULL")
	assert(target_location, "target_location is NULL")
	
	var pathway = []
	
	var current_location = start_location
	current_location.local_goal = 0.0
	current_location.global_goal = map.manhatten_distance(start_location, target_location)
	
	var untested_locations = []
	untested_locations.push_back(start_location)
	
	while (!untested_locations.empty() && !current_location.equals(target_location)):
		
		untested_locations.sort_custom(CustomSorter, "sort_global_goals")
		
		while (!untested_locations.empty() && untested_locations.front().visited):
			untested_locations.pop_front()
			
		if (untested_locations.empty()):
			break
			
		current_location = untested_locations.front()
		current_location.visited = true
		
		var current_neighbors = current_location.get_neighbors(false, filter_tags)
		
		for neighbor in current_neighbors:
			
			untested_locations.push_back(neighbor)
			
			var goal_calculation = current_location.local_goal + map.manhatten_distance(current_location, neighbor)
			
			if (goal_calculation < neighbor.local_goal):
				
				neighbor.parent = current_location
				neighbor.local_goal = goal_calculation
				neighbor.global_goal = neighbor.local_goal + map.manhatten_distance(neighbor, target_location)
				
	var location = target_location
	while (location.parent):

		pathway.push_front(location)
		location = location.parent
		
	pathway.push_front(start_location)

	map.reset_all_locations()
	return pathway
