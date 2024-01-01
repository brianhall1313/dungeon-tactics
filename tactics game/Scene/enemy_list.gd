extends BattleLists
var list
var alive_list:Array
var dead_list:Array


# Called when the node enters the scene tree for the first time.
func _ready():
	list=get_children()
	alive_list=list.duplicate()

func remove(character):
	for x in list:
		if x == character:
			dead_list.append(character)
			alive_list.erase(character)
			character.cMove.move(Global.dead_position,Global.dead_position_raw)
