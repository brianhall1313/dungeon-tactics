extends Node

var player_party:Array=[]
var player_inventory: Array=[]
var player_gold: int=0
var level_progress:Dictionary={}


func load_data(data:Dictionary):
	player_party = data['party'].duplicate(true)
	player_inventory= data['inventory'].duplicate()
	player_gold = data['gold']
	level_progress = data['progress']

func level_complete(level:String):
	level_progress[level] = true

func item_get(item:String):
	player_inventory.append(item)

func gold_get(amount:int):
	player_gold += amount
	
func character_get(character:Dictionary):
	player_party.append(character)
