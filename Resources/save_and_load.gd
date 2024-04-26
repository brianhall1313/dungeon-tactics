extends Node
@export var save_dictionary: Dictionary={}
@export var data_path="user://save_data_"



func save_game(data, slot):
	var full_path = data_path + str(slot) + '.save'
	var save_file=FileAccess.open(full_path,FileAccess.WRITE)
	var json_string = JSON.stringify(data)
	save_file.store_line(json_string)


func load_game(slot:int):
	var data = load_json(slot)
	if data:
		print('data loaded')
		return data
	else:
		print("Data failed to load")
		return data


func load_json(slot:int):
	var full_path = data_path + str(slot) + '.save'
	if FileAccess.file_exists(full_path):
		var data_file=FileAccess.open(full_path,FileAccess.READ)
		var parsed_data=JSON.parse_string(data_file.get_as_text())
		if parsed_data is Dictionary:
			#print(parsed_data)
			return parsed_data
		else:
			print('parsed data is not a dictionary')
			return false
	else:
		print('Json parse error:file does not exist')
		return false


func load_metadata(slot:int):
	var full_path = data_path + str(slot) + '.save'
	if FileAccess.file_exists(full_path):
		var data_file=FileAccess.open(full_path,FileAccess.READ)
		var parsed_data=JSON.parse_string(data_file.get_as_text())
		if parsed_data is Dictionary:
			#print(parsed_data)
			return parsed_data['metadata']
		else:
			return false
	else:
		return false



func load_party_data(slot:int):
	var full_path = data_path + str(slot) + '.save'
	if FileAccess.file_exists(full_path):
		var data_file=FileAccess.open(full_path,FileAccess.READ)
		var parsed_data=JSON.parse_string(data_file.get_as_text())
		if parsed_data is Dictionary:
			#print(parsed_data)
			return parsed_data['party']
		else:
			return false
	else:
		return false

func load_default_data():
	var party : Dictionary={"gold":0,
	"inventory":[],
	"metadata":{"last save":"2024-04-24T14:45:37","wizard":"Erasmus"},
	"party":[
		{"abilities":[],"character_name":"Capri","equipment":{"armor":"heavy_armor","off_hand":"shield","weapon":"sword"},"experience":0,"inventory":[],"job":"knight","level":0,"spells":[],"stats":{"armor":13,"combat":4,"health":12,"move":6,"ranged_combat":0,"will":1},"tags":["humanoid"]},
		{"abilities":[],"character_name":"Darrell","equipment":{"armor":"light_armor","ranged_weapon":"bow","weapon":"sword"},"experience":0,"inventory":[],"job":"ranger","level":0,"spells":[],"stats":{"armor":11,"combat":2,"health":12,"move":7,"ranged_combat":2,"will":2},"tags":["humanoid"]},
		{"job":"templar","tags":["humanoid"],"stats":{"move":6,"combat":4,"ranged_combat":0,"armor":10,"will":1,"health":12},"equipment":{"weapon":"great_weapon","armor":"heavy_armor"},"spells":[],"abilities":[]},
		{"job":"infantryman","tags":["humanoid"],"stats":{"move":6,"combat":3,"ranged_combat":0,"armor":10,"will":0,"health":10},"equipment":{"weapon":"great_weapon","armor":"light_armor"},"spells":[],"abilities":[]},
		{"job":"thug","tags":["humanoid"],"stats":{"move":6,"combat":2,"ranged_combat":0,"armor":10,"will":-1,"health":10},"equipment":{"weapon":"hand_weapon"},"spells":[],"abilities":[]},
		{"job":"archer","tags":["humanoid"],"stats":{"move":6,"combat":1,"ranged_combat":2,"armor":10,"will":0,"health":10},"equipment":{"ranged_weapon":"bow","weapon":"dagger","armor":"light_armor"},"spells":[],"abilities":[],},
		{"abilities":[],"job":"treasure_hunter","tags":["humanoid"],"stats":{"move":7,"combat":3,"ranged_combat":0,"armor":10,"will":2,"health":12},"equipment":{"weapon":"hand_weapon","armor":"light_armor"}},
		{"abilities":["Heavy Strike"],"job":"barbarian",'stats':{"move":6,"combat":4,"ranged_combat":0,"armor":10,"will":3,"health":14},"equipment":{"weapon":"great_weapon"},"experience":0,"inventory":[],"level":0,"spells":[],"tags":["humanoid"]},
		{"abilities":[],"character_name":"Erasmus","equipment":{"weapon":"staff"},"experience":0,"inventory":[],"job":"wizard","level":0,"spells":["Elemental Bolt","Elemental Blast","Summon Undead","Heal"],"stats":{"armor":10,"combat":2,"health":14,"move":6,"ranged_combat":0,"will":4},"tags":["humanoid","wizard"]},
		{"abilities":[],"character_name":"Eliza","equipment":{"weapon":"staff"},"experience":0,"inventory":[],"job":"apprentice","level":0,"spells":["Elemental Bolt","Elemental Blast","Summon Undead","Heal"],"stats":{"armor":10,"combat":1,"health":12,"move":6,"ranged_combat":0,"will":2},"tags":["humanoid","apprentice"]},
		],
		"progress":{"road":false,"test":false}}
	return party
