extends Node
@export var beast_weapons:Dictionary={}
@export var data_path="res://Resources/beast_weapons.json"
# Called when the node enters the scene tree for the first time.
func _ready():
	beast_weapons=load_json()
	if beast_weapons:
		print('beast_weapons loaded')
	else:
		print('failed to load beast_weapons')

func load_json():
	if FileAccess.file_exists(data_path):
		var data_file=FileAccess.open(data_path,FileAccess.READ)
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
