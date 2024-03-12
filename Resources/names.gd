extends Node
@export var names:Dictionary={}
@export var data_path="res://Resources/names.json"
# Called when the node enters the scene tree for the first time.
func _ready():
	names=load_json()
	if names:
		print('names loaded')
	else:
		print('failed to load names')

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


func get_random_name(type=null):
	var selected_name:String
	if type:
		selected_name=names[type].pick_random()
	else:
		var num = randi_range(0,1)
		if num == 0:
			selected_name=names['boys'].pick_random()
		else:
			selected_name=names['girls'].pick_random()
	return selected_name
