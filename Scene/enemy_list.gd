extends BattleLists
var list:Array
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
			character.position=Global.dead_position

func revive(character,pos):
	if character in dead_list:
		alive_list.append(character)
		dead_list.erase(character)
		character.position=pos
