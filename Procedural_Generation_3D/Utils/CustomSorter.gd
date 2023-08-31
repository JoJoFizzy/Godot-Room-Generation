extends Node
class_name CustomSorter

static func sort_global_goals(a, b):
	
	if (a.global_goal < b.global_goal):
		
		return true
		
	return false
