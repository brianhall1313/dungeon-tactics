extends Node
@export var bestiary:Dictionary={}
@export var data_path="res://Resources/bestiary.json"
# Called when the node enters the scene tree for the first time.
func _ready():
	bestiary=load_json()
	if bestiary:
		print('bestiary loaded')
	else:
		print('failed to load bestiary')

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
