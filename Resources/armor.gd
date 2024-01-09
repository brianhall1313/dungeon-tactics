extends Node
@export var armor_dictionary:Dictionary={}
@export var data_path="res://Resources/armor.json"
# Called when the node enters the scene tree for the first time.
func _ready():
	armor_dictionary=load_json()
	if armor_dictionary:
		print('armor loaded')
	else:
		print('failed to load armor')

func load_json():
	if FileAccess.file_exists(data_path):
		var data_file=FileAccess.open(data_path,FileAccess.READ)
		var parsed_data=JSON.parse_string(data_file.get_as_text())
		if parsed_data is Dictionary:
			print(parsed_data)
			return parsed_data
		else:
			print('parsed data is not a dictionary')
			return false
	else:
		print('Json parse error:file does not exist')
		return false
