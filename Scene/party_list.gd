extends BattleLists
var list:Array=[]
var alive_list:Array=[]
var dead_list:Array=[]

signal ai_list_handover(list_pointer)

# Called when the node enters the scene tree for the first time.
func _ready():
	GlobalSignalBus.connect('turn_start',_on_turn_start)



func full_turn_start():
	for character in alive_list:
		character.turn_start()
	print(alive_list_print())
		

func alive_list_print():
	var name_list:String=''
	for x in alive_list:
		name_list+=x.character_name+' '
	return name_list



func remove(character):
	for x in list:
		if x == character:
			dead_list.append(character)
			alive_list.erase(character)
			character.position=Global.dead_position
			if len(alive_list)==0:
				GlobalSignalBus.party_wipe.emit(dead_list[0].faction)

func revive(character,pos):
	if character in dead_list:
		alive_list.append(character)
		dead_list.erase(character)
		character.position=pos
		character.turn_start()


func add(character_data, return_copy = false):
	var new_character=Global.character.instantiate()
	add_child(new_character)
	if return_copy:
		return new_character
	var children=get_children()
	for x in children:
		if !x in list:
			x.character_setup(character_data)
			list.append(x)
			alive_list.append(x)
			x.turn_start()
			GlobalSignalBus.place_character_default.emit(x)
			print('character added')



func ai_handover():
	ai_list_handover.emit(self)

func is_turn_over():
	for character in alive_list:
		if character.turn_tracker['turn_complete']==false:
			return false
	return true

func _on_turn_start(turn):
	print("passing info to the ai")
	if turn == 'enemy':
		ai_handover()
