extends Node
class_name GC

#PUBLIC:

enum TAGS {TEST, EMPTY, ROOM, WALL, CORRIDOR, DOOR}
const MIN_ROOM_SIZE = 5 # Square Dimension val x val
const NUMBER_OF_DOORS = 2 # Number of doors for each room

const BSP_COUNT = 3  # Must be less than log(minimum dimension / (2 * MIN_ROOM_SIZE)) / log(2) + 1
					 # gives 2^n partitions
					
const SPATIAL_UNIT_3D = 1 # for 3D map
const SPATIAL_UNIT_2D = 8 # for 2D mini-map (zooms the minimap in and out)
