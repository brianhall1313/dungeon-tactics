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
		{"abilities":["Heavy Strike"],"character_name":"Capri","equipment":["heavy_armor","shield","sword"],"experience":0,"inventory":[],"job":"knight","level":0,"spells":[],"stats":{"armor":13,"combat":4,"health":12,"move":6,"ranged_combat":0,"will":1},"tags":["humanoid"]},
		{"abilities":["Heavy Shot"],"character_name":"Darrell","equipment":["light_armor","bow","sword"],"experience":0,"inventory":[],"job":"ranger","level":0,"spells":[],"stats":{"armor":11,"combat":2,"health":12,"move":7,"ranged_combat":2,"will":2},"tags":["humanoid"]},
		{"job":"templar","tags":["humanoid"],"stats":{"move":6,"combat":4,"ranged_combat":0,"armor":10,"will":1,"health":12},"equipment":["great_weapon","heavy_armor"],"spells":[],"abilities":["Heavy Strike"]},
		{"job":"infantryman","tags":["humanoid"],"stats":{"move":6,"combat":3,"ranged_combat":0,"armor":10,"will":0,"health":10},"equipment":["great_weapon","light_armor"],"spells":[],"abilities":["Heavy Strike"]},
		{"job":"thug","tags":["humanoid"],"stats":{"move":6,"combat":2,"ranged_combat":0,"armor":10,"will":-1,"health":10},"equipment":["hand_weapon"],"spells":[],"abilities":["Heavy Strike"]},
		{"job":"archer","tags":["humanoid"],"stats":{"move":6,"combat":1,"ranged_combat":2,"armor":10,"will":0,"health":10},"equipment":["bow","dagger","light_armor"],"spells":[],"abilities":["Heavy Shot"],},
		{"abilities":["Heavy Strike"],"job":"treasure_hunter","tags":["humanoid"],"stats":{"move":7,"combat":3,"ranged_combat":0,"armor":10,"will":2,"health":12},"equipment":["hand_weapon","light_armor"]},
		{"abilities":["Heavy Strike"],"job":"barbarian",'stats':{"move":6,"combat":4,"ranged_combat":0,"armor":10,"will":3,"health":14},"equipment":["great_weapon"],"experience":0,"inventory":[],"level":0,"spells":[],"tags":["humanoid"]},
		{"abilities":[],"character_name":"Erasmus","equipment":["staff"],"experience":0,"inventory":[],"job":"wizard","level":0,"spells":["Elemental Bolt","Elemental Blast","Summon Undead","Heal"],"stats":{"armor":10,"combat":2,"health":14,"move":6,"ranged_combat":0,"will":4},"tags":["humanoid","wizard"]},
		{"abilities":[],"character_name":"Eliza","equipment":["staff"],"experience":0,"inventory":[],"job":"apprentice","level":0,"spells":["Elemental Bolt","Elemental Blast","Summon Undead","Heal"],"stats":{"armor":10,"combat":1,"health":12,"move":6,"ranged_combat":0,"will":2},"tags":["humanoid","apprentice"]},
		],
		"progress":{"entrance":false,"guard":false,"descent":false}}
	return party
