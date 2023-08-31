extends Node

#PUBLIC:

onready var debug_hud = $DebugHUD
onready var level_manager = $LevelManager


#PRIVATE:

var _LEVEL = preload("res://Levels/Level.gd")
var _test_level = _LEVEL.new()
var _another_test_level = _LEVEL.new()


func _ready():
	
	level_manager.init()
	_test_level.init(40, 70, "test_level", 22)
	#_another_test_level.init(40, 70, "another_test_level", 25)

	level_manager.change_level(_test_level)
	#level_manager.change_level(_another_test_level)
	
	#debug_hud.init(level_manager)
	
func _process(delta):
	
	level_manager.update()
	
	#debug_hud.update()
