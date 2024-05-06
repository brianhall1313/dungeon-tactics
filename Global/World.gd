extends Node


#defaults if load fails
var player_party:Array=[]
var player_inventory: Array=[]
var player_gold: int=0
var level_progress:Dictionary={"entrance":false,
								"guard":false,
								"descent":false,
								}


func load_data(data:Dictionary):
	if data['party']:
		player_party = data['party'].duplicate(true)
	if data['inventory']:
		player_inventory= data['inventory'].duplicate()
	if data['gold']:
		player_gold = data['gold']
	if data['progress']:
		level_progress = data['progress'].duplicate()

func level_complete(level:String):
	level_progress[level] = true

func item_get(item:String):
	player_inventory.append(item)

func gold_get(amount:int):
	player_gold += amount
	
func character_get(character:Dictionary):
	player_party.append(character)
	
func save():
	var data: Dictionary ={}
	var wizard:String="default"
	for character in player_party:
		if character["job"]== 'wizard':
			wizard=character.character_name
	data['metadata']={"wizard":wizard,"last save":Time.get_datetime_string_from_system()}
	data['party']= player_party.duplicate(true)
	data['inventory']= World.player_inventory.duplicate(true)
	data['gold']=World.player_gold
	data['progress']=World.level_progress.duplicate()
	return data
	#SaveAndLoad.load_game(1)

func load_default_data():
	var data : Dictionary = SaveAndLoad.load_default_data()
	if data['party']:
		player_party = data['party'].duplicate(true)
	if data['inventory']:
		player_inventory= data['inventory'].duplicate()
	if data['gold']:
		player_gold = data['gold']
	if data['progress']:
		level_progress = data['progress'].duplicate()
