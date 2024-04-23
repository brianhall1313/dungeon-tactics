extends Node
@export var level_data:Array=[]
@export var data_path="res://Resources/level_data.Json"
# Called when the node enters the scene tree for the first time.
func _ready():
	level_data=load_json()
	if level_data:
		print('level data loaded')
	else:
		print('failed to load level data')

func load_json():
	if FileAccess.file_exists(data_path):
		var data_file=FileAccess.open(data_path,FileAccess.READ)
		var parsed_data=JSON.parse_string(data_file.get_as_text())
		if parsed_data is Array:
			#print(parsed_data)
			return parsed_data
		else:
			print('parsed data is not a dictionary')
			return false
	else:
		print('Json parse error:file does not exist')
		return false
